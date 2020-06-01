from flask import Flask
from flask import render_template
import json

row = {}
row["uid"] = "User1"
row["password"] = "User1"
row["service"] = "User1"
row["content"] = "User1"

rows = [row]

app = Flask(__name__)

@app.route("/")
def home():
    return render_template('./index.html')

@app.route("/update")
def update():
    f = ""
    with open("./assets/test.json", "r") as x:
        f = x.read()
    return(f)


if __name__ == "__main__":
    print(json.dumps(rows))

    app.run(host="0.0.0.0", port=8080)
