from flask import (
	Blueprint, flash, g, redirect, render_template,
	request, url_for, abort, current_app
)
import urllib
import json

bp = Blueprint("pages", __name__, static_folder="static")

@bp.route("/")
def index():
	return render_template("index.html")

@bp.route("/update")
def update():
	with open(current_app.config["DATA"], "r") as f:
		return f.read()
