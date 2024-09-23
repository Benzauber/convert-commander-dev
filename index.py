from flask import Flask, request, render_template, redirect, url_for, jsonify, send_file
import os
import text

app = Flask(__name__)
UPLOAD_FOLDER = '/home/ben/convert-commander/uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Stelle sicher, dass der Upload-Ordner existiert
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Globale Variable zur Speicherung von filetest
global_filetest = None

def download_file(filepath, global_filetest):    
    filename = os.path.splitext(os.path.basename(filepath))[0]
    filethepath = f'/home/ben/convert-commander/test/pdfs/{filename}.{global_filetest}'
    try:
        print(filethepath)
        return send_file(filethepath, as_attachment=True)
    except Exception as e:
        return str(e)

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

            # Hier umleiten zur Download-Route
            return redirect(url_for('download', filename=file.filename))
        
        elif file:
            return redirect(url_for('index', status='Datei hochgeladen, aber filetest nicht verfügbar'))

    return render_template('index.html', status=request.args.get('status'))

@app.route('/download/<filename>', methods=['GET'])
def download(filename):
    global global_filetest
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    return download_file(filepath, global_filetest)

@app.route('/empfange_daten', methods=['POST'])
def empfange_daten():
    global global_filetest
    daten = request.json['daten']
    global_filetest = daten
    print(f"Empfangene Daten: {daten}")
    return jsonify({"status": "erfolgreich empfangen", "message": "Bitte laden Sie jetzt eine Datei hoch"})

if __name__ == '__main__':
    app.run(debug=True, host= "192.168.1.94")
