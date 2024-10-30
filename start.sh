#!/bin/bash

# Pfad zu den Python-Skripten
PYTHON_SCRIPT_WEB="index:app"  # Format: "dateiname:app_name"
PYTHON_SCRIPT_API="api:app"  # Format: "dateiname:app_name"

# PID-Dateien für die Gunicorn-Prozesse
PID_FILE_WEB="/tmp/gunicorn_web.pid"
PID_FILE_API="/tmp/gunicorn_api.pid"

# Gunicorn-Befehl zum Starten des Prozesses, inklusive Ports
GUNICORN_CMD_WEB="gunicorn --bind 0.0.0.0:5000 --daemon --pid"
GUNICORN_CMD_API="gunicorn --bind 0.0.0.0:5001 --daemon --pid"

# Funktion zum Überprüfen, ob ein Prozess läuft
check_status() {
    local PID_FILE=$1
    local SERVICE_NAME=$2

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            echo "$SERVICE_NAME läuft (PID: $PID)"
        else
            echo "$SERVICE_NAME läuft nicht, PID-Datei gefunden, aber Prozess nicht aktiv"
            rm "$PID_FILE"
        fi
    else
        echo "$SERVICE_NAME läuft nicht"
    fi
}

# Starten des Gunicorn-Prozesses
start_service() {
    local SCRIPT_NAME=$1
    local PID_FILE=$2
    local GUNICORN_CMD=$3

    if [ -f "$PID_FILE" ] && ps -p "$(cat $PID_FILE)" > /dev/null; then
        echo "$SCRIPT_NAME läuft bereits"
    else
        $GUNICORN_CMD "$PID_FILE" "$SCRIPT_NAME" &
        echo "$SCRIPT_NAME wurde gestartet"
    fi
}

# Stoppen des Gunicorn-Prozesses
stop_service() {
    local PID_FILE=$1
    local SERVICE_NAME=$2

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill "$PID" 2>/dev/null
        rm "$PID_FILE"
        echo "$SERVICE_NAME wurde gestoppt"
    else
        echo "$SERVICE_NAME läuft nicht"
    fi
}

# Hauptlogik zur Auswahl des Dienstes und der Aktion
case "$1" in
    web)
        case "$2" in
            start)
                start_service "$PYTHON_SCRIPT_WEB" "$PID_FILE_WEB" "$GUNICORN_CMD_WEB"
                ;;
            stop)
                stop_service "$PID_FILE_WEB" "Web-Dienst"
                ;;
            status)
                check_status "$PID_FILE_WEB" "Web-Dienst"
                ;;
            *)
                echo "Verwendung: $0 {web|api} {start|stop|status}"
                exit 1
                ;;
        esac
        ;;
    api)
        case "$2" in
            start)
                start_service "$PYTHON_SCRIPT_API" "$PID_FILE_API" "$GUNICORN_CMD_API"
                ;;
            stop)
                stop_service "$PID_FILE_API" "API-Dienst"
                ;;
            status)
                check_status "$PID_FILE_API" "API-Dienst"
                ;;
            *)
                echo "Verwendung: $0 {web|api} {start|stop|status}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Verwendung: $0 {web|api} {start|stop|status}"
        exit 1
        ;;
esac

exit 0
