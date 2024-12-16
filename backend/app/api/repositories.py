import logging
from flask import jsonify, request, g
from sqlalchemy.exc import SQLAlchemyError
from . import api
from app.models.settings import Settings
from app.models.repository import Repository

FRAMEOS_SAMPLES_URL = "https://repo.frameos.net/samples/repository.json"
FRAMEOS_GALLERY_URL = "https://repo.frameos.net/gallery/repository.json"

@api.route("/repositories", methods=["POST"])
def create_repository():
    db = g.db
    data = request.json or {}
    url = data.get('url')

    if not url:
        return jsonify({'error': 'Missing URL'}), 400

    try:
        new_repository = Repository(name="", url=url)
        new_repository.update_templates()
        db.add(new_repository)
        db.commit()
        return jsonify(new_repository.to_dict()), 201
    except SQLAlchemyError as e:
        logging.error(f'Database error: {e}')
        return jsonify({'error': 'Database error'}), 500

@api.route("/repositories", methods=["GET"])
def get_repositories():
    db = g.db
    try:
        # We have created an old repo URL. Remove it.
        if db.query(Settings).filter_by(key="@system/repository_init_done").first():
            old_url = "https://repo.frameos.net/versions/0/templates.json"
            repository = db.query(Repository).filter_by(url=old_url).first()
            if repository:
                db.delete(repository)
            db.delete(db.query(Settings).filter_by(key="@system/repository_init_done").first())
            db.commit()

        # We have not created a new samples repo URL
        if not db.query(Settings).filter_by(key="@system/repository_samples_done").first():
            repository = Repository(name="", url=FRAMEOS_SAMPLES_URL)
            repository.update_templates()
            db.add(repository)
            db.add(Settings(key="@system/repository_samples_done", value="true"))
            db.commit()

        # We have not created a new gallery repo URL
        if not db.query(Settings).filter_by(key="@system/repository_gallery_done").first():
            repository = Repository(name="", url=FRAMEOS_GALLERY_URL)
            repository.update_templates()
            db.add(repository)
            db.add(Settings(key="@system/repository_gallery_done", value="true"))
            db.commit()

        repositories = [repo.to_dict() for repo in db.query(Repository).all()]
        return jsonify(repositories)
    except SQLAlchemyError as e:
        logging.error(f'Database error: {e}')
        return jsonify({'error': 'Database error'}), 500

@api.route("/repositories/<repository_id>", methods=["GET"])
def get_repository(repository_id):
    db = g.db
    try:
        repository = db.query(Repository).get(repository_id)
        if not repository:
            return jsonify({"error": "Repository not found"}), 404
        return jsonify(repository.to_dict())
    except SQLAlchemyError as e:
        logging.error(f'Database error: {e}')
        return jsonify({'error': 'Database error'}), 500

@api.route("/repositories/<repository_id>", methods=["PATCH"])
def update_repository(repository_id, ):
    db = g.db
    data = request.json or {}
    try:
        repository = db.query(Repository).get(repository_id)
        if not repository:
            return jsonify({"error": "Repository not found"}), 404

        if data.get('name'):
            repository.name = data.get('name', repository.name)
        if data.get('url'):
            repository.url = data.get('url', repository.url)
        repository.update_templates()
        db.commit()
        return jsonify(repository.to_dict())
    except SQLAlchemyError as e:
        logging.error(f'Database error: {e}')
        return jsonify({'error': 'Database error'}), 500

@api.route("/repositories/<repository_id>", methods=["DELETE"])
def delete_repository(repository_id):
    db = g.db
    try:
        repository = db.query(Repository).get(repository_id)
        if not repository:
            return jsonify({"error": "Repository not found"}), 404
        db.delete(repository)
        db.commit()
        return jsonify({"message": "Repository deleted successfully"}), 200
    except SQLAlchemyError as e:
        logging.error(f'Database error: {e}')
        return jsonify({'error': 'Database error'}), 500
