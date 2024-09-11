import subprocess
import os
def start(file):
    def convert_file(input_file, output_file):
        if not os.path.exists(input_file):
            print(f"Die Eingabedatei '{input_file}' existiert nicht.")
            return

        output_dir = os.path.dirname(output_file)
        if not os.path.exists(output_dir):
            print(f"Der Ausgabeordner '{output_dir}' existiert nicht.")
            return

        command = [
            'libreoffice',
            '--headless',
            '--convert-to', 'txt',
            '--outdir', output_dir,
            input_file
        ]

        try:
            result = subprocess.run(command, check=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            print(f"Konvertierung erfolgreich abgeschlossen: {result.stdout.decode()}")
        except subprocess.CalledProcessError as e:
            print(f"Fehler beim Konvertieren: {e.stderr.decode()}")
            print(f"Ausgabe: {e.stdout.decode()}")

    if __name__ == "__main__":
        input_file = '/home/ben/convert-commander/uploads'+ file
        output_file = '/home/ben/convert-commander/test/pdfs/text2.txt'
    
        # Debug-Ausgabe für das Arbeitsverzeichnis
        print(f"Arbeitsverzeichnis: {os.getcwd()}")
        print(f"Ausgabeordner: {os.path.dirname(output_file)}")
    
        convert_file(input_file, output_file)
        print(f"Die Datei '{input_file}' wurde erfolgreich in '{output_file}' konvertiert.")
