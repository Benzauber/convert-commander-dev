from flask import Flask, request, jsonify, send_file, make_response
from flask_swagger_ui import get_swaggerui_blueprint
import os
import pandoc
import libre
import ffmpeg
from flask_cors import CORS
import shutil
import logging
from werkzeug.utils import secure_filename
import mimetypes
import secrets
import hashlib
from functools import wraps

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

UPLOAD_FOLDER = 'uploads'
CONVERT_FOLDER = 'convert'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['CONVERT_FOLDER'] = CONVERT_FOLDER

pandoc_formats = [
    "markdown", "rst", "asciidoc", "org", "muse", "textile", "markua", "txt2tags", "djot",
    "html", "xhtml", "html5", "chunked-html",
    "epub", "fictionbook2",
    "texinfo", "haddock",
    "roff-man", "roff-ms", "mdoc-man",
    "latex", "context",
    "docbook", "jats", "bits", "tei", "opendocument", "opml",
    "bibtex", "biblatex", "csl-json", "csl-yaml", "ris", "endnote",
    "docx", "rtf", "odt",
    "ipynb",
    "icml", "typst",
    "mediawiki", "dokuwiki", "tikimediawiki", "twiki", "vimwiki", "xwiki", "zimwiki", "jira-wiki", "creole",
    "beamer", "pptx", "slidy", "revealjs", "slideous", "s5", "dzslides",
    "csv", "tsv",
    "ansi-text",
    "pdf", "txt"
]

libreoffice_formats = ["xls", "xlsx", "ods", "ppt", "pptx", "odp"]

ffmpeg_formats = [
    'mp4', 'avi', 'mov', 'mkv', 'webm', 'flv', 'wmv', 'mpeg', 'mpg', 'ts', '3gp', 'mp3', 'wav', 'aac', 'flac',
    'ogg', 'm4a', 'wma', 'ac3', 'amr', 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp', 'mxf', 'vob',
    'asf', 'dv', 'm3u8', 'mpd'
    ]

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(CONVERT_FOLDER, exist_ok=True)

logging.basicConfig(level=logging.DEBUG)

SWAGGER_URL = '/docs'
API_URL = '/static/swagger.json'

swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={
        'app_name': "Convert-Commander API"
    }
)

app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

hashed_tokens = set()

def generate_token():
    return secrets.token_urlsafe(32)

def hash_token(token):
    """ Generate a SHA-256 hash of the token."""
    return hashlib.sha256(token.encode()).hexdigest()

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('X-API-Token')
        if not token:
            return jsonify({'error': 'API token is missing'}), 401
        hashed_token = hash_token(token)
        if hashed_token not in hashed_tokens:
            return jsonify({'error': 'Invalid API token'}), 401
        return f(*args, **kwargs)
    return decorated

@app.route('/generate_token', methods=['POST'])
def create_token():
    """
    Generate a new API token
    ---
    tags:
      - Authentication
    responses:
      200:
        description: New API token generated
    """
    token = generate_token()
    hashed_token = hash_token(token)
    hashed_tokens.add(hashed_token)  
    return jsonify({'token': token}), 200  

def delete_files_in_folder(folder_path):
    if os.path.exists(folder_path):
        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)
            except Exception as e:
                logging.error(f'Error deleting {file_path}. Reason: {e}')
    else:
        logging.warning(f'Folder {folder_path} does not exist')

@app.route('/upload', methods=['POST'])
@token_required
def upload_file():
    """
    Upload a file and convert it to the specified format
    ---
    tags:
      - File Conversion
    consumes:
      - multipart/form-data
    parameters:
      - in: header
        name: X-API-Token
        type: string
        required: true
        description: API token for authentication
      - in: formData
        name: file
        type: file
        required: true
        description: The file to upload
      - in: formData
        name: format
        type: string
        required: true
        description: The target format for conversion
    responses:
      200:
        description: Successfully converted file
      400:
        description: Invalid request
      401:
        description: Unauthorized
      500:
        description: Server error
    """
    if 'file' not in request.files or 'format' not in request.form:
        return jsonify({'error': 'No file or format specified'}), 400

    file = request.files['file']
    target_format = request.form['format']
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    logging.info(f"File uploaded: {filepath}")

    try:
        logging.debug(f"Starting conversion from {filepath} to {target_format}")

        if target_format in libreoffice_formats:
          print("Libreoffice")
          libre.start(filepath, target_format)
        elif target_format in pandoc_formats:
          print("Pandoc")
          pandoc.start(filepath, target_format)
        elif target_format in ffmpeg_formats:
          print("Ffmpeg")
          ffmpeg.start(filepath, target_format)
 
        
        converted_filename = os.path.splitext(filename)[0] + f'.{target_format}'
        converted_filepath = os.path.join(app.config['CONVERT_FOLDER'], converted_filename)

        if not os.path.exists(converted_filepath):
            return jsonify({'error': 'Converted file not found'}), 500

        logging.debug(f"Sending converted file: {converted_filepath}")
        
        mime_type, _ = mimetypes.guess_type(converted_filepath)
        if mime_type is None:
            mime_type = 'application/octet-stream'

        with open(converted_filepath, 'rb') as f:
            file_data = f.read()

        response = make_response(file_data)
        response.headers.set('Content-Type', mime_type)
        response.headers.set('Content-Disposition', f'attachment; filename="{converted_filename}"')
        response.headers.set('Content-Length', str(os.path.getsize(converted_filepath)))

        logging.debug(f"Sent headers: {response.headers}")

        return response

    except Exception as e:
        logging.error(f"Error during conversion: {str(e)}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/clear', methods=['POST'])
@token_required
def clear_folders():
    """
    Clear all files in the upload and conversion folders
    ---
    tags:
      - Maintenance
    parameters:
      - in: header
        name: X-API-Token
        type: string
        required: true
        description: API token for authentication
    responses:
      200:
        description: Folders successfully cleared
      401:
        description: Unauthorized
    """
    delete_files_in_folder(app.config['UPLOAD_FOLDER'])
    delete_files_in_folder(app.config['CONVERT_FOLDER'])
    return jsonify({'message': 'Folders cleared'}), 200



if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port="9596")
