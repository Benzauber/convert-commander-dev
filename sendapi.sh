#!/bin/bash

FILE_PATH=$1
TARGET_FORMAT=$2
API_URL="http://192.168.1.94:5001/upload"

if [ -z "$FILE_PATH" ] || [ -z "$TARGET_FORMAT" ]; then
  echo "Usage: $0 <file_path> <target_format>"
  exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
  echo "File not found!"
  exit 1
fi

# Extrahiere den Dateinamen ohne Pfad
FILENAME=$(basename "$FILE_PATH")
# Entferne die ursprüngliche Dateiendung
FILENAME_WITHOUT_EXT="${FILENAME%.*}"
# Erstelle den neuen Dateinamen mit der Zielformat-Endung
NEW_FILENAME="${FILENAME_WITHOUT_EXT}.${TARGET_FORMAT}"

# Sende die Datei mit dem Zielformat an die API und speichere die Antwort
curl -v -X POST -F "file=@$FILE_PATH" -F "format=$TARGET_FORMAT" $API_URL -o "$NEW_FILENAME"

if [ $? -eq 0 ]; then
  echo "Konvertierung erfolgreich. Die konvertierte Datei wurde als '$NEW_FILENAME' gespeichert."
else
  echo "Fehler bei der Konvertierung."
  exit 1
fi