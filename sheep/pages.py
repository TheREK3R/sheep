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


@bp.route("/packets/<int:num>")
def update(num):
	packets = getPackets()
	return json.dumps(packets[0:num])


def getPackets():
	try:
		with open(current_app.config["DATA"], "r") as f:
			return json.loads(f.read())
	except Exception as e:
		print("Error reading packet data:", e)
		return None
