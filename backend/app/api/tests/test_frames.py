import pytest
from unittest.mock import patch
import httpx

from app.models import new_frame
from app.models.frame import Frame

@pytest.mark.asyncio
async def test_api_frames(async_client, db_session, redis):
    # Create a frame:
    await new_frame(db_session, redis, 'TestFrame', 'localhost', 'localhost')

    # GET /api/frames
    response = await async_client.get('/api/frames')
    assert response.status_code == 200
    data = response.json()
    assert 'frames' in data
    assert len(data['frames']) == 1
    assert data['frames'][0]['name'] == 'TestFrame'

@pytest.mark.asyncio
async def test_api_frame_get_found(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'FoundFrame', 'localhost', 'localhost')
    response = await async_client.get(f'/api/frames/{frame.id}')
    assert response.status_code == 200
    data = response.json()
    assert 'frame' in data
    assert data['frame']['name'] == 'FoundFrame'

@pytest.mark.asyncio
async def test_api_frame_get_not_found(async_client):
    # Large ID that doesn't exist
    response = await async_client.get('/api/frames/999999')
    assert response.status_code == 404
    assert response.json()['detail'] == 'Frame not found'

@pytest.mark.asyncio
async def test_api_frame_get_image_cached(async_client, db_session, redis):
    # Create the frame
    frame = await new_frame(db_session, redis, 'CachedImageFrame', 'localhost', 'localhost')
    cache_key = f'frame:{frame.frame_host}:{frame.frame_port}:image'
    await redis.set(cache_key, b'cached_image_data')

    # We pass t=-1 to force the code to return the cached data
    image_link_resp = await async_client.get(f'/api/frames/{frame.id}/image_link')
    assert image_link_resp.status_code == 200
    link_info = image_link_resp.json()
    image_url = link_info['url']
    # e.g. /api/frames/{frame.id}/image?token=XYZ

    # Append t=-1
    image_url += "&t=-1"
    response = await async_client.get(image_url)
    assert response.status_code == 200
    assert response.content == b'cached_image_data'

@pytest.mark.asyncio
async def test_api_frame_get_image_no_cache(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'NoCacheFrame', 'example.com', 'localhost')
    # no cache set
    # Patch httpx.AsyncClient.get to return a 200 with image_data
    async def mock_httpx_get(url, **kwargs):
        class MockResponse:
            status_code = 200
            content = b'image_data'
        return MockResponse()

    with patch.object(httpx.AsyncClient, 'get', side_effect=mock_httpx_get):
        link_resp = await async_client.get(f'/api/frames/{frame.id}/image_link')
        image_url = link_resp.json()['url']
        response = await async_client.get(image_url)
        assert response.status_code == 200
        assert response.content == b'image_data'

        # Now it should be cached:
        cache_key = f'frame:{frame.frame_host}:{frame.frame_port}:image'
        cached = await redis.get(cache_key)
        assert cached == b'image_data'

@pytest.mark.asyncio
async def test_api_frame_event_render(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'RenderFrame', 'example.com', 'localhost')
    # Mock out the call to the frame’s /event/render
    async def mock_httpx_post(url, **kwargs):
        class MockResponse:
            status_code = 200
        return MockResponse()

    with patch.object(httpx.AsyncClient, 'post', side_effect=mock_httpx_post):
        response = await async_client.post(f'/api/frames/{frame.id}/event/render')
        assert response.status_code == 200
        assert response.text == '"OK"'

@pytest.mark.asyncio
async def test_api_frame_event_render_unreachable(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'FailFrame', 'example.com', 'localhost')
    async def mock_httpx_post(url, **kwargs):
        class MockResponse:
            status_code = 500
        return MockResponse()
    with patch.object(httpx.AsyncClient, 'post', side_effect=mock_httpx_post):
        response = await async_client.post(f'/api/frames/{frame.id}/event/render')
        assert response.status_code == 500
        assert response.json()['detail'] == 'Unable to reach frame'

@pytest.mark.asyncio
async def test_api_frame_reset_event(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'ResetFrame', 'example.com', 'localhost')
    response = await async_client.post(f'/api/frames/{frame.id}/reset')
    assert response.status_code == 200
    assert response.text == '"Success"'

@pytest.mark.asyncio
async def test_api_frame_not_found_for_reset(async_client):
    response = await async_client.post('/api/frames/999999/reset')
    # The route does not look up the frame; it just calls reset_frame(999999).
    # If you wanted a 404, you'd need to do a db lookup first. Right now, we return 200 "Success".
    # Adjust this test if your code actually checks for existence.
    assert response.status_code == 200
    assert response.text == '"Success"'

@pytest.mark.asyncio
async def test_api_frame_update_name(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'InitialName', 'localhost', 'localhost')
    response = await async_client.post(f'/api/frames/{frame.id}', json={"name": "Updated Name"})
    assert response.status_code == 200
    updated_frame = db_session.get(Frame, frame.id)
    assert updated_frame.name == "Updated Name"

@pytest.mark.asyncio
async def test_api_frame_update_scenes_json_format(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'SceneTest', 'localhost', 'localhost')
    # Scenes as a JSON string
    response = await async_client.post(f'/api/frames/{frame.id}', json={
        "scenes": '[{"sceneName":"Scene1"},{"sceneName":"Scene2"}]'
    })
    assert response.status_code == 200
    updated = db_session.get(Frame, frame.id)
    assert updated.scenes == [{"sceneName": "Scene1"}, {"sceneName": "Scene2"}]

@pytest.mark.asyncio
async def test_api_frame_update_scenes_invalid(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'SceneTest2', 'localhost', 'localhost')
    response = await async_client.post(f'/api/frames/{frame.id}', json={
        "scenes": "not valid JSON"
    })
    assert response.status_code == 400
    assert "Invalid input for scenes" in response.json()['detail']

@pytest.mark.asyncio
async def test_api_frame_new(async_client):
    # Valid creation
    payload = {
        "name": "NewFrame",
        "frame_host": "myhost",
        "server_host": "myserver"
    }
    response = await async_client.post('/api/frames/new', json=payload)
    assert response.status_code == 200
    data = response.json()
    assert 'frame' in data
    assert data['frame']['name'] == "NewFrame"

@pytest.mark.asyncio
async def test_api_frame_new_missing_fields(async_client):
    # Missing frame_host
    payload = {
        "name": "BadFrame"
    }
    response = await async_client.post('/api/frames/new', json=payload)
    assert response.status_code == 500
    assert "Missing required fields" in response.json()['detail']

@pytest.mark.asyncio
async def test_api_frame_delete(async_client, db_session, redis):
    frame = await new_frame(db_session, redis, 'DeleteMe', 'localhost', 'localhost')
    response = await async_client.delete(f'/api/frames/{frame.id}')
    assert response.status_code == 200
    assert response.json()['message'] == "Frame deleted successfully"

@pytest.mark.asyncio
async def test_api_frame_delete_not_found(async_client):
    response = await async_client.delete('/api/frames/999999')
    assert response.status_code == 404
    assert response.json()['detail'] == 'Frame not found'
