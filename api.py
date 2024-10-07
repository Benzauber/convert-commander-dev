from flask import Flask, request, jsonify, send_file, make_response
from flask_swagger_ui import get_swaggerui_blueprint
import os
import text  # Ihr Konvertierungsskript
from flask_cors import CORS
import shutil
import logging
from werkzeug.utils import secure_filename
import mimetypes

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

UPLOAD_FOLDER = '/home/ben/convert-commander/uploads'
CONVERT_FOLDER = '/home/ben/convert-commander/convert'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['CONVERT_FOLDER'] = CONVERT_FOLDER

# Stelle sicher, dass die Ordner existieren
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(CONVERT_FOLDER, exist_ok=True)

# Konfiguriere Logging
logging.basicConfig(level=logging.DEBUG)

# Swagger UI Konfiguration
SWAGGER_URL = '/docs'  # URL für Swagger UI
API_URL = '/static/swagger.json'  # Wo die Swagger-Spezifikationen gefunden werden können

swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={
        'app_name': "File Converter API"
    }
)

app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

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
                logging.error(f'Fehler beim Löschen {file_path}. Grund: {e}')
    else:
        logging.warning(f'Ordner {folder_path} existiert nicht')

@app.route('/upload', methods=['POST'])
def upload_file():
    """
    Lade eine Datei hoch und konvertiere sie in das angegebene Format
    ---
    tags:
      - File Conversion
    consumes:
      - multipart/form-data
    parameters:
      - in: formData
        name: file
        type: file
        required: true
        description: Die hochzuladende Datei
      - in: formData
        name: format
        type: string
        required: true
        description: Das Zielformat für die Konvertierung
    responses:
      200:
        description: Erfolgreich konvertierte Datei
      400:
        description: Ungültige Anfrage
      500:
        description: Serverfehler
    """
    if 'file' not in request.files or 'format' not in request.form:
        return jsonify({'error': 'Keine Datei oder Format angegeben'}), 400

    file = request.files['file']
    target_format = request.form['format']
    
    if file.filename == '':
        return jsonify({'error': 'Keine Datei ausgewählt'}), 400

    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    logging.info(f"Datei hochgeladen: {filepath}")

    try:
        logging.debug(f"Starte Konvertierung von {filepath} zu {target_format}")
        text.start(filepath, target_format)
        
        converted_filename = os.path.splitext(filename)[0] + f'.{target_format}'
        converted_filepath = os.path.join(app.config['CONVERT_FOLDER'], converted_filename)

        if not os.path.exists(converted_filepath):
            return jsonify({'error': 'Konvertierte Datei nicht gefunden'}), 500

        logging.debug(f"Sende konvertierte Datei: {converted_filepath}")
        
        mime_type, _ = mimetypes.guess_type(converted_filepath)
        if mime_type is None:
            mime_type = 'application/octet-stream'

        with open(converted_filepath, 'rb') as f:
            file_data = f.read()

        response = make_response(file_data)
        response.headers.set('Content-Type', mime_type)
        response.headers.set('Content-Disposition', f'attachment; filename="{converted_filename}"')
        response.headers.set('Content-Length', str(os.path.getsize(converted_filepath)))

        logging.debug(f"Gesendete Header: {response.headers}")

        return response

    except Exception as e:
        logging.error(f"Fehler bei der Konvertierung: {str(e)}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/clear', methods=['POST'])
def clear_folders():
    """
    Lösche alle Dateien in den Upload- und Konvertierungsordnern
    ---
    tags:
      - Maintenance
    responses:
      200:
        description: Ordner erfolgreich geleert
    """
    delete_files_in_folder(app.config['UPLOAD_FOLDER'])
    delete_files_in_folder(app.config['CONVERT_FOLDER'])
    return jsonify({'message': 'Ordner geleert'}), 200

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5001)