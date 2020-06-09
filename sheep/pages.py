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
	if packets is None:
		return {}
	return json.dumps(packets[0:num])


def getPackets():
	try:
		with open(current_app.config["DATA"], "r") as f:
			data = f.readlines()
			if data == "" or data is None or len(data) == 0:
				return None

			packets = []
			for d in data:
				packets.append(json.loads(d))

			return [censor(p) for p in packets]
	except Exception as e:
		print("Error reading packet data:", e)
		return None


def censor(packet):
	pw = packet.get("password")
	if not pw:
		return None

	show = int(len(pw) / 4)
	hide = len(pw) - (show * 2)
	if hide > 1:
		pw = pw[:show] + ("*" * hide) + pw[-show:]
	else:
		pw = "*" * len(pw)
	packet["password"] = pw
	return packet
