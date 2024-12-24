import os
import subprocess
import shutil

# Liste der Dateitypen, die konvertiert werden sollen
convert_types = [
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
    "pdf"
]

# Funktion zum Konvertieren
def convert_file(input_file, output_type, output_folder):
    try:
        # Bestimme den Zielpfad
        output_file = os.path.join(output_folder, f"{os.path.splitext(os.path.basename(input_file))[0]}_{output_type}.txt")
        
        # Pandoc-Konvertierung durchführen
        result = subprocess.run(
            ['pandoc', input_file, '-o', output_file, '-t', output_type],
            capture_output=True, text=True
        )
        
        # Überprüfen, ob es Fehler gibt
        if result.returncode == 0:
            return output_file
        else:
            print(f"Fehler beim Konvertieren der Datei '{input_file}' in {output_type}: {result.stderr}")
            return None
    except Exception as e:
        print(f"Fehler beim Konvertieren der Datei '{input_file}': {e}")
        return None

# Funktion zum Verarbeiten der Dateien im Ordner
def process_files(folder_path, output_folder, output_file):
    with open(output_file, 'w') as output:
        for filename in os.listdir(folder_path):
            input_file = os.path.join(folder_path, filename)
            
            if os.path.isfile(input_file):
                # Für jede Datei durch alle angegebenen Dateitypen konvertieren
                conversion_results = []
                for output_type in convert_types:
                    converted_file = convert_file(input_file, output_type, output_folder)
                    if converted_file:
                        conversion_results.append(output_type)
                
                if conversion_results:
                    output.write(f"{filename} = {', '.join(conversion_results)}\n")
                    print(f"Datei '{filename}' wurde erfolgreich konvertiert: {', '.join(conversion_results)}")
                else:
                    print(f"Keine Konvertierungen für '{filename}' durchgeführt.")
    
    # Lösche den Output-Ordner nach Abschluss der Konvertierung
    try:
        shutil.rmtree(output_folder)
        print(f"Der Ordner '{output_folder}' wurde nach der Verarbeitung gelöscht.")
    except Exception as e:
        print(f"Fehler beim Löschen des Ordners '{output_folder}': {e}")

# Ordnerpfad und Textdatei zur Ausgabe
folder_path = '/home/ben/convert-commander/convert-test/file'  # Hier den richtigen Pfad eintragen
output_folder = '/home/ben/convert-commander/convert-test/output'  # Zielordner für die konvertierten Dateien
output_file = 'conversion_results.txt'

# Sicherstellen, dass der Zielordner existiert
os.makedirs(output_folder, exist_ok=True)

# Starten des Verarbeitungsprozesses
process_files(folder_path, output_folder, output_file)
