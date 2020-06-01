# Wall of Sheep

An open-source credential shaming system written in Python 3.

## Installation

For the simplest method (might require sudo), just do this:

```bash
pip3 install flask
```

For an isolated installation, the process is a bit more involved:

```bash
# First install the isolated package environment
# manager if it isn't already available.
pip3 install virtualenv

# Next create a new virtual environment
virtualenv --python=python3 venv

# Activate the virtual environment in Bash.
# There are other scripts for other shells, like activate.fish and .ps1
source venv/bin/activate

# Once inside venv, pip will install packages isolated from your system
pip install flask

# When you're done with flask, exit the virtual environment
deactivate
```

## Usage

If you're using `virtualenv`, then first run `source venv/bin/activate`. Run `deactivate` or exit the shell to leave the virtual environment.

### Commands

* `flask run` starts the server. Visit http://127.0.0.1:5000 in your browser.

## Contributor Info

* Flask has a built-in development server that supports auto-reload on source change and shows an interactive debugger on errors. Run it with `FLASK_ENV=development flask run`.

* Flask also has a shell that's useful for debugging. Use `flask shell`, then access modules after importing them: `import sheep.pages as pages`.
