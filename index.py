from flask import Flask, request, render_template, redirect, url_for, jsonify
import os
import text

app = Flask(__name__)
UPLOAD_FOLDER = '/home/ben/convert-commander/uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Stelle sicher, dass der Upload-Ordner existiert
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Globale Variable zur Speicherung von filetest
global_filetest = None

@app.route('/', methods=['GET', 'POST'])
def index():
    global global_filetest
    if request.method == 'POST':
        if 'file' not in request.files:
            return redirect(url_for('index', status='Keine Datei ausgewählt'))
        
        file = request.files['file']
        
        if file.filename == '':
            return redirect(url_for('index', status='Keine Datei ausgewählt'))
        
        if file and global_filetest is not None:
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
            file.save(filepath)
            text.start(filepath, global_filetest)
            global_filetest = None  # Zurücksetzen nach Verwendung
            return redirect(url_for('index', status=f'Datei {file.filename} erfolgreich hochgeladen und verarbeitet'))
        elif file:
            return redirect(url_for('index', status='Datei hochgeladen, aber filetest nicht verfügbar'))
            
    return render_template('index.html', status=request.args.get('status'))

@app.route('/empfange_daten', methods=['POST'])
def empfange_daten():
    global global_filetest
    daten = request.json['daten']
    global_filetest = daten
    print(f"Empfangene Daten: {daten}")
    return jsonify({"status": "erfolgreich empfangen", "message": "Bitte laden Sie jetzt eine Datei hoch"})

if __name__ == '__main__':
    app.run(debug=True)