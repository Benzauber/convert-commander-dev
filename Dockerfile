# Basis-Image
FROM python:3.9-slim

# Umgebungsvariablen, um interaktive Eingaben zu vermeiden
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Arbeitsverzeichnis im Container erstellen
WORKDIR /app

# Systempakete installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    libreoffice-common libreoffice-java-common libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-headless \
    ffmpeg \
    pandoc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Abhängigkeiten kopieren und installieren
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Projektdateien kopieren
COPY . .

# Ordner für Uploads und Konvertierungen erstellen
RUN mkdir -p ./uploads ./convert

# Ausführbare Skripte
RUN chmod +x create-alias.sh tokenapi.sh

# Standardbefehl beim Start des Containers
CMD ["python3", "index.py"]
