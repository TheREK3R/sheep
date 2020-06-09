from flask import Flask, render_template, request
from flask_httpauth import HTTPBasicAuth
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
auth = HTTPBasicAuth()

# https://github.com/miguelgrinberg/Flask-HTTPAuth#basic-authentication-example
users = {
    "ba_admin": generate_password_hash("password")
}

@auth.verify_password
def verify_password(username, password):
    if username in users and check_password_hash(users.get(username), password):
        return username

@app.route("/basic")
@auth.login_required
def basic():
    return f"Hello {auth.current_user()}"

@app.route("/postform", methods=["GET", "POST"])
def postform():
    if request.method == "GET":
        return render_template("post.html")
    else:
        return "Thanks for your response!"

@app.route("/getform")
def getform():
    username = request.args.get("username")
    if username:
        return "Thanks for your response!"
    else:
        return render_template("get.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=1337)