#!/bin/bash

# Name des Python-Skripts
PYTHON_SCRIPT="index.py"
# PID-Datei zur Prozessverwaltung
PID_FILE="/tmp/python_script.pid"

# Funktion zum Überprüfen ob das Skript läuft
check_status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            echo "Python-Skript läuft (PID: $PID)"
            return 0
        else
            rm "$PID_FILE"
            echo "Python-Skript läuft nicht"
            return 1
        fi
    else
        echo "Python-Skript läuft nicht"
        return 1
    fi
}

# Starten des Skripts
start() {
    if check_status > /dev/null; then
        echo "Python-Skript läuft bereits"
    else
        python3 "$PYTHON_SCRIPT" &
        echo $! > "$PID_FILE"
        echo "Python-Skript wurde gestartet"
    fi
}

# Stoppen des Skripts
stop() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill "$PID" 2>/dev/null
        rm "$PID_FILE"
        echo "Python-Skript wurde gestoppt"
    else
        echo "Python-Skript läuft nicht"
    fi
}

# Hauptlogik
case "$1" in
api)
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        check_status
        ;;
    *)
        echo "Verwendung: $0 {start|stop|status}"
        exit 1
        ;;
web)   
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        check_status
        ;;
    *)
        echo "Verwendung: $0 {start|stop|status}"
        exit 1
        ;;     
esac

exit 0