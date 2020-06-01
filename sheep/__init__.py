# Application factory and Python's package marker
import os
from flask import Flask

def create_app():
	# create and configure the app
	app = Flask(__name__, instance_relative_config=True)

	app.config.from_mapping(
		SECRET_KEY="dev",
		DATA=os.path.join(app.instance_path, "test.json")
	)

	try:
		os.makedirs(app.instance_path)
	except OSError:
		pass

	from . import pages
	app.register_blueprint(pages.bp)
	app.add_url_rule("/", endpoint="index")

	return app
