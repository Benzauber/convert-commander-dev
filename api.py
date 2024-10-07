from flask import Flask, request, jsonify, send_file, url_for
import os
import text  # Ihr Konvertierungsskript
from flask_cors import CORS
import shutil
import logging

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

def delete_files_in_folder(folder_path):
    if os.path.exists(folder_path):
        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)  # Datei oder symbolischen Link löschen
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)  # Ordner und dessen Inhalt löschen
            except Exception as e:
                logging.error(f'Fehler beim Löschen {file_path}. Grund: {e}')
    else:
        logging.warning(f'Ordner {folder_path} existiert nicht')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files or 'format' not in request.form:
        return jsonify({'error': 'Keine Datei oder Format angegeben'}), 400

    file = request.files['file']
    target_format = request.form['format']
    
    if file.filename == '':
        return jsonify({'error': 'Keine Datei ausgewählt'}), 400

    # Speichern der hochgeladenen Datei
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
    file.save(filepath)

    logging.info(f"Datei hochgeladen: {filepath}")

    # Datei konvertieren
    try:
        logging.debug(f"Starte Konvertierung von {filepath} zu {target_format}")
        text.start(filepath, target_format)  # Konvertierungslogik aus text.py
        
        # Erstellen des neuen Dateinamens basierend auf dem Ziel-Format
        converted_filename = os.path.splitext(file.filename)[0] + f'.{target_format}'
        converted_filepath = os.path.join(app.config['CONVERT_FOLDER'], converted_filename)

        logging.debug(f"Überprüfe konvertierte Datei: {converted_filepath}")
        if not os.path.exists(converted_filepath):
            return jsonify({'error': 'Konvertierte Datei nicht gefunden'}), 500

        logging.debug(f"Sende konvertierte Datei: {converted_filepath}")
        return send_file(converted_filepath, as_attachment=True, download_name=converted_filename, mimetype='application/octet-stream')
    except Exception as e:
        logging.error(f"Fehler bei der Konvertierung: {str(e)}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/download/<filename>')
def download_file(filename):
    filepath = os.path.join(app.config['CONVERT_FOLDER'], filename)
    if not os.path.exists(filepath):
        return jsonify({'error': 'Datei nicht gefunden'}), 404
    return send_file(filepath, as_attachment=True)

@app.route('/clear', methods=['POST'])
def clear_folders():
    # Lösche Dateien aus den Upload- und Konvertierungsordnern
    delete_files_in_folder(app.config['UPLOAD_FOLDER'])
    delete_files_in_folder(app.config['CONVERT_FOLDER'])
    return jsonify({'message': 'Ordner geleert'}), 200

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5001)