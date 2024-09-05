import subprocess
import os

def convert_pdf_to_odt(pdf_file):
    # Überprüfen, ob die Datei existiert
    if not os.path.exists(pdf_file):
        print(f"Die Datei {pdf_file} wurde nicht gefunden.")
        return

    # Zielpfad: gleiche Datei mit der Endung .odt
    output_file = os.path.splitext(pdf_file)[0] + '.odt'

    try:
        # Verwende unoconv, um das PDF in ODT zu konvertieren
        subprocess.run(['unoconv', '-f', 'odt', pdf_file], check=True)
        print(f"Erfolgreich konvertiert: {pdf_file} -> {output_file}")
    except subprocess.CalledProcessError as e:
        print(f"Fehler bei der Konvertierung: {e}")

if __name__ == "__main__":
    # Beispiel-PDF-Datei (Pfad zur Datei anpassen)
    pdf_file = '/home/ben/convert-commander/test/pdfs/text.txt'
    
    # Konvertiere die PDF-Datei in ODT
    convert_pdf_to_odt(pdf_file)
