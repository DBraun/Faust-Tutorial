import argparse
import os

from flask import Flask, send_from_directory, abort
from flask_cors import CORS

app = Flask(__name__)

# Specify trusted origins
trusted_origins = os.getenv("TRUSTED_ORIGINS", "http://localhost,http://127.0.0.1,https://faustide.grame.fr").split(",")

CORS(app, origins=trusted_origins)

# Define a variable for the static files directory
STATIC_FILES_DIR = None

@app.route('/<path:filename>')
def download_file(filename):
    # Simple validation to prevent directory traversal
    if ".." in filename or filename.startswith("/"):
        abort(404)  # Not found for invalid paths
    return send_from_directory(STATIC_FILES_DIR, filename)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('--port', type=int, default=8000, help="Port")
    parser.add_argument('--debug', action=argparse.BooleanOptionalAction, help="Enable or disable debug mode")
    parser.add_argument('--assets-dir', type=str, default='assets', help="Directory to serve static files from")

    args = parser.parse_args()

    # Set the static files directory
    STATIC_FILES_DIR = args.assets_dir
    os.makedirs(STATIC_FILES_DIR, exist_ok=True)  # Ensure the directory exists

    app.run(debug=args.debug, port=args.port)
