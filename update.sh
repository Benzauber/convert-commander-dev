#!/bin/bash

# Dynamisch das Verzeichnis des Skripts herausfinden
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Starting Convert-Commander update process..."

# Schritt 1: Ins Projektverzeichnis wechseln
cd "$PROJECT_DIR" || { echo "Projektverzeichnis nicht gefunden! Abbruch."; exit 1; }

# Schritt 2: Änderungen von Git abrufen
echo "Pulling latest changes from GitHub..."
git pull || { echo "Fehler beim Abrufen der Änderungen von GitHub! Abbruch."; exit 1; }

# Schritt 3: Virtuelle Umgebung aktivieren
echo "Activating virtual environment..."
source venv/bin/activate || { echo "Fehler beim Aktivieren der virtuellen Umgebung! Abbruch."; exit 1; }

# Schritt 4: Abhängigkeiten aktualisieren
echo "Updating Python dependencies..."
pip install --upgrade -r requirements.txt || { echo "Fehler beim Aktualisieren der Abhängigkeiten! Abbruch."; exit 1; }

# Schritt 5: Dienst neu starten (optional)
SERVICE_NAME="convert-commander" # Passe den Dienstnamen an
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Restarting the Convert-Commander service..."
    sudo systemctl restart "$SERVICE_NAME" || { echo "Fehler beim Neustarten des Dienstes! Abbruch."; exit 1; }
else
    echo "Service is not running, skipping restart."
fi

echo "Update process completed successfully!"
