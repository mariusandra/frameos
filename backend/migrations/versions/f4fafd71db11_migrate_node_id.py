"""migrate node_id

Revision ID: f4fafd71db11
Revises: fa715fc28251
Create Date: 2024-01-18 23:47:48.016511

"""
from sqlalchemy.orm import attributes, load_only


# revision identifiers, used by Alembic.
revision = 'f4fafd71db11'
down_revision = 'fa715fc28251'
branch_labels = None
depends_on = None


def upgrade():
    from app.models import Frame
    from app.database import SessionLocal
    db = SessionLocal()
    frames = db.query(Frame).options(load_only(Frame.id, Frame.scenes)).all()
    for frame in frames:
        frame.scenes = list(frame.scenes)
        changed = False
        for scene in frame.scenes:
            for node in scene.get('nodes', []):
                if node.get('type', None) == 'app' and 'data' in node:
                    sources = node['data'].get('sources', {})
                    if 'app.nim' in sources:
                        source = sources['app.nim']
                        node['data']['sources']['app.nim'] = source.replace('nodeId*: string', 'nodeId*: NodeId').replace('nodeId: string', 'nodeId: NodeId')
                        changed = True
        if changed:
            attributes.flag_modified(frame, "scenes")
            db.add(frame)
            db.commit()
    db.flush()
    db.close()

def downgrade():
    from app.models import Frame
    from app.database import SessionLocal
    db = SessionLocal()
    frames = db.query(Frame).all()
    for frame in frames:
        frame.scenes = list(frame.scenes)
        changed = False
        for scene in frame.scenes:
            for node in scene.get('nodes', []):
                if node.get('type', None) == 'app' and 'data' in node:
                    sources = node['data'].get('sources', {})
                    if 'app.nim' in sources:
                        source = sources['app.nim']
                        node['data']['sources']['app.nim'] = source.replace('nodeId*: NodeId', 'nodeId*: string').replace('nodeId: NodeId', 'nodeId: string')
                        changed = True
        if changed:
            attributes.flag_modified(frame, "scenes")
            db.add(frame)
            db.commit()
    db.flush()
    db.close()