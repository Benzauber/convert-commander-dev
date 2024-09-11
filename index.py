from flask import Flask, request, render_template, redirect, url_for
import os


app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Stelle sicher, dass der Upload-Ordner existiert
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        # Überprüfe, ob eine Datei hochgeladen wurde
        if 'file' not in request.files:
            return redirect(url_for('index', status='Keine Datei ausgewählt'))
        
        file = request.files['file']
        
        if file.filename == '':
            return redirect(url_for('index', status='Keine Datei ausgewählt'))
        
        if file:
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], file.filename))
            return redirect(url_for('index', status=f'Datei {file.filename} erfolgreich hochgeladen'))
            
 
    # Wenn es eine GET-Anfrage ist, wird die HTML-Datei angezeigt
    return render_template('index.html', status=request.args.get('status'))

if __name__ == '__main__':
    app.run(debug=True)
