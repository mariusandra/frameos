import json
import os
from datetime import timezone
from redis.asyncio import Redis
from typing import Optional
from sqlalchemy.dialects.sqlite import JSON
from sqlalchemy import Integer, String, Double, DateTime, Boolean
from sqlalchemy.orm import Session, mapped_column
from app.database import Base

from app.models.apps import get_app_configs
from app.models.settings import get_settings_dict
from app.utils.token import secure_token
from app.websockets import publish_message


# NB! Update frontend/src/types.tsx if you change this
class Frame(Base):
    __tablename__ = 'frame'
    id = mapped_column(Integer, primary_key=True)
    name = mapped_column(String(256), nullable=False)
    # sending commands to frame
    frame_host = mapped_column(String(256), nullable=False)
    frame_port = mapped_column(Integer, default=8787)
    frame_access_key = mapped_column(String(256), nullable=True)
    frame_access = mapped_column(String(50), nullable=True)
    ssh_user = mapped_column(String(50), nullable=True)
    ssh_pass = mapped_column(String(50), nullable=True)
    ssh_port = mapped_column(Integer, default=22)
    # receiving logs, connection from frame to us
    server_host = mapped_column(String(256), nullable=True)
    server_port = mapped_column(Integer, default=8989)
    server_api_key = mapped_column(String(64), nullable=True)
    # frame metadata
    status = mapped_column(String(15), nullable=False)
    version = mapped_column(String(50), nullable=True)
    width = mapped_column(Integer, nullable=True)
    height = mapped_column(Integer, nullable=True)
    device = mapped_column(String(256), nullable=True)
    color = mapped_column(String(256), nullable=True)
    interval = mapped_column(Double, default=300)
    metrics_interval = mapped_column(Double, default=60)
    scaling_mode = mapped_column(String(64), nullable=True)  # contain (default), cover, stretch, center
    rotate = mapped_column(Integer, nullable=True)
    log_to_file = mapped_column(String(256), nullable=True)
    assets_path = mapped_column(String(256), nullable=True)
    save_assets = mapped_column(JSON, nullable=True)
    debug = mapped_column(Boolean, nullable=True)
    last_log_at = mapped_column(DateTime, nullable=True)
    reboot = mapped_column(JSON, nullable=True)
    control_code = mapped_column(JSON, nullable=True)
    # apps
    apps = mapped_column(JSON, nullable=True)
    scenes = mapped_column(JSON, nullable=True, default=list)

    # deprecated
    image_url = mapped_column(String(256), nullable=True)
    background_color = mapped_column(String(64), nullable=True) # still used as fallback in frontend

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'frame_host': self.frame_host,
            'frame_port': self.frame_port,
            'frame_access_key': self.frame_access_key,
            'frame_access': self.frame_access,
            'ssh_user': self.ssh_user,
            'ssh_pass': self.ssh_pass,
            'ssh_port': self.ssh_port,
            'server_host': self.server_host,
            'server_port': self.server_port,
            'server_api_key': self.server_api_key,
            'status': self.status,
            'version': self.version,
            'width': self.width,
            'height': self.height,
            'device': self.device,
            'color': self.color,
            'interval': self.interval,
            'metrics_interval': self.metrics_interval,
            'scaling_mode': self.scaling_mode,
            'rotate': self.rotate,
            'background_color': self.background_color,
            'debug': self.debug,
            'scenes': self.scenes,
            'last_log_at': self.last_log_at.replace(tzinfo=timezone.utc).isoformat() if self.last_log_at else None,
            'log_to_file': self.log_to_file,
            'assets_path': self.assets_path,
            'save_assets': self.save_assets,
            'reboot': self.reboot,
            'control_code': self.control_code,
        }

async def new_frame(db: Session, redis: Redis, name: str, frame_host: str, server_host: str, device: Optional[str] = None, interval: Optional[float] = None) -> Frame:
    if '@' in frame_host:
        user_pass, frame_host = frame_host.split('@')
    else:
        user_pass, frame_host = 'pi', frame_host

    if ':' in frame_host:
        frame_host, ssh_port_initial = frame_host.split(':')
        ssh_port = int(ssh_port_initial or '22')
        if ssh_port > 65535 or ssh_port < 0:
            raise ValueError("Invalid frame port")
    else:
        ssh_port = 22

    if ':' in user_pass:
        user, password = user_pass.split(':')
    else:
        user, password = user_pass, None

    if ':' in server_host:
        server_host, server_port_initial = server_host.split(':')
        server_port = int(server_port_initial or '8989')
    else:
        server_port = 8989

    frame = Frame(
        name=name,
        ssh_user=user,
        ssh_pass=password,
        ssh_port=ssh_port,
        frame_host=frame_host,
        frame_access_key=secure_token(20),
        frame_access="private",
        server_host=server_host,
        server_port=int(server_port),
        server_api_key=secure_token(32),
        interval=interval or 60,
        status="uninitialized",
        apps=[],
        scenes=[],
        scaling_mode="contain",
        rotate=0,
        device=device or "web_only",
        log_to_file=None, # spare the SD card from load
        assets_path='/srv/assets',
        save_assets=True,
        control_code={"enabled": "true", "position": "top-right"},
        reboot={"enabled": "true", "crontab": "4 0 * * *"},
    )
    db.add(frame)
    db.commit()
    await publish_message(redis, "new_frame", frame.to_dict())

    from app.models import new_log
    await new_log(db, redis, int(frame.id), "welcome", f"The frame \"{frame.name}\" has been created!")

    return frame


async def update_frame(db: Session, redis: Redis, frame: Frame):
    db.add(frame)
    db.commit()
    await publish_message(redis, "update_frame", frame.to_dict())


async def delete_frame(db: Session, redis: Redis, frame_id: int):
    if frame := db.get(Frame, frame_id):
        # delete corresonding log and metric entries first
        from .log import Log
        db.query(Log).filter_by(frame_id=frame_id).delete()
        from .metrics import Metrics
        db.query(Metrics).filter_by(frame_id=frame_id).delete()

        cache_key = f'frame:{frame.frame_host}:{frame.frame_port}:image'
        await redis.delete(cache_key)

        db.delete(frame)
        db.commit()
        await publish_message(redis, "delete_frame", {"id": frame_id})
        return True
    return False


def get_templates_json() -> dict:
    templates_schema_path = os.path.join("..", "frontend", "schema", "templates.json")
    if os.path.exists(templates_schema_path):
        with open(templates_schema_path, 'r') as file:
            return json.load(file)
    else:
        return {}

def get_frame_json(db: Session, frame: Frame) -> dict:
    frame_json: dict = {
        "name": frame.name,
        "frameHost": frame.frame_host or "localhost",
        "framePort": frame.frame_port or 8787,
        "frameAccessKey": frame.frame_access_key,
        "frameAccess": frame.frame_access,
        "serverHost": frame.server_host or "localhost",
        "serverPort": frame.server_port or 8989,
        "serverApiKey": frame.server_api_key,
        "width": frame.width,
        "height": frame.height,
        "device": frame.device or "web_only",
        "metricsInterval": frame.metrics_interval or 60.0,
        "debug": frame.debug or False,
        "scalingMode": frame.scaling_mode or "contain",
        "rotate": frame.rotate or 0,
        "logToFile": frame.log_to_file,
        "assetsPath": frame.assets_path,
        "saveAssets": frame.save_assets,
    }

    setting_keys = set()
    app_configs = get_app_configs()
    for scene in list(frame.scenes):
        for node in scene.get('nodes', []):
            if node.get('type', None) == 'app':
                sources = node.get('data', {}).get('sources', None)
                if sources and len(sources) > 0:
                    try:
                        config = sources.get('config.json', '{}')
                        config = json.loads(config)
                        settings = config.get('settings', [])
                        for key in settings:
                            setting_keys.add(key)
                    except:  # noqa: E722
                        pass
                else:
                    keyword = node.get('data', {}).get('keyword', None)
                    if keyword:
                        app_config = app_configs.get(keyword, None)
                        if app_config:
                            settings = app_config.get('settings', [])
                            for key in settings:
                                setting_keys.add(key)

    all_settings = get_settings_dict(db)
    final_settings = {}
    for key in setting_keys:
        final_settings[key] = all_settings.get(key, None)

    frame_json['settings'] = final_settings
    return frame_json
