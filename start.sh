#!/bin/bash

# Virtuelle Umgebung aktivieren
source "$(dirname "$0")/venv/bin/activate"

# Logging-Konfiguration
LOG_DIR="/var/log/ccommander"
mkdir -p "$LOG_DIR"
MAIN_LOG="$LOG_DIR/ccommander.log"

# Pfade und Konfigurationen
PYTHON_SCRIPT_WEB="index:app"
PYTHON_SCRIPT_API="api:app"
PID_FILE_WEB="/tmp/gunicorn_web.pid"
PID_FILE_API="/tmp/gunicorn_api.pid"
BACKUP_DIR="$LOG_DIR/backups"

# Gunicorn-Konfiguration mit verbessertem Logging
GUNICORN_CMD_WEB="gunicorn --bind 0.0.0.0:9595 --daemon --pid $PID_FILE_WEB --error-logfile $LOG_DIR/gunicorn_web_error.log --access-logfile $LOG_DIR/gunicorn_web_access.log --capture-output --log-level info"
GUNICORN_CMD_API="gunicorn --bind 0.0.0.0:9596 --daemon --pid $PID_FILE_API --error-logfile $LOG_DIR/gunicorn_api_error.log --access-logfile $LOG_DIR/gunicorn_api_access.log --capture-output --log-level info"

# Logging-Funktion
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$MAIN_LOG"
    echo "[$level] $message"
}

# Erweiterte Fehlerbehandlung
handle_error() {
    local error_message=$1
    log_message "ERROR" "$error_message"
    exit 1
}

# Funktion zum Überprüfen der Systemvoraussetzungen
check_requirements() {
    which gunicorn >/dev/null 2>&1 || handle_error "Gunicorn ist nicht installiert"
    [ -d "venv" ] || handle_error "Virtuelle Umgebung nicht gefunden"
    [ -f "requirements.txt" ] || log_message "WARNING" "requirements.txt nicht gefunden"
}

# Erweiterte Status-Überprüfung
check_status() {
    local PID_FILE=$1
    local SERVICE_NAME=$2
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            log_message "INFO" "$SERVICE_NAME läuft (PID: $PID)"
            # Prozess-Details ausgeben
            echo "Prozess-Details:"
            ps -p "$PID" -o pid,ppid,user,%cpu,%mem,start,time,command
        else
            log_message "WARNING" "$SERVICE_NAME läuft nicht, PID-Datei gefunden aber Prozess inaktiv"
            rm "$PID_FILE"
        fi
    else
        log_message "INFO" "$SERVICE_NAME läuft nicht"
    fi
}

# Verbesserte Start-Funktion
start_service() {
    local SCRIPT_NAME=$1
    local PID_FILE=$2
    local GUNICORN_CMD=$3
    local SERVICE_NAME=$4

    if [ -f "$PID_FILE" ] && ps -p "$(cat $PID_FILE)" > /dev/null; then
        log_message "WARNING" "$SERVICE_NAME läuft bereits"
    else
        log_message "INFO" "Starte $SERVICE_NAME..."
        $GUNICORN_CMD "$SCRIPT_NAME"
        sleep 2
        if [ -f "$PID_FILE" ] && ps -p "$(cat $PID_FILE)" > /dev/null; then
            log_message "INFO" "$SERVICE_NAME erfolgreich gestartet"
        else
            handle_error "$SERVICE_NAME konnte nicht gestartet werden"
        fi
    fi
}

# Verbesserte Stop-Funktion
stop_service() {
    local PID_FILE=$1
    local SERVICE_NAME=$2

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        log_message "INFO" "Stoppe $SERVICE_NAME (PID: $PID)..."
        if kill -15 "$PID" 2>/dev/null; then
            # Warte bis zu 10 Sekunden auf ordnungsgemäße Beendigung
            for i in {1..10}; do
                if ! ps -p "$PID" > /dev/null; then
                    break
                fi
                sleep 1
            done
            # Falls Prozess immer noch läuft, force kill
            if ps -p "$PID" > /dev/null; then
                log_message "WARNING" "$SERVICE_NAME reagiert nicht, führe Force-Kill durch"
                kill -9 "$PID" 2>/dev/null
            fi
            rm "$PID_FILE"
            log_message "INFO" "$SERVICE_NAME wurde gestoppt"
        else
            handle_error "Konnte $SERVICE_NAME nicht stoppen"
        fi
    else
        log_message "INFO" "$SERVICE_NAME läuft nicht"
    fi
}

# Update-Funktionen
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$timestamp"
    
    mkdir -p "$backup_path" || handle_error "Backup-Verzeichnis konnte nicht erstellt werden"
    log_message "INFO" "Erstelle Backup in $backup_path"
    
    # Backup relevanter Dateien
    cp -r venv requirements.txt *.py *.sh "$backup_path/" 2>/dev/null
    if [ $? -eq 0 ]; then
        log_message "INFO" "Backup erfolgreich erstellt"
    else
        log_message "WARNING" "Einige Dateien konnten nicht gesichert werden"
    fi
}

perform_update() {
    log_message "INFO" "Starte Update-Prozess..."
    
    # Prüfe ob Services laufen
    local services_running=false
    if [ -f "$PID_FILE_WEB" ] || [ -f "$PID_FILE_API" ]; then
        services_running=true
        log_message "WARNING" "Services laufen noch, werden für Update gestoppt"
        stop_service "$PID_FILE_WEB" "Web-Dienst"
        stop_service "$PID_FILE_API" "API-Dienst"
    fi
    
    create_backup
    
    # Update Python-Pakete
    log_message "INFO" "Aktualisiere Python-Pakete..."
    pip install -r requirements.txt --upgrade || handle_error "Python-Paket-Update fehlgeschlagen"
    
    # Starte Services neu wenn sie vorher liefen
    if [ "$services_running" = true ]; then
        log_message "INFO" "Starte Services neu..."
        start_service "$PYTHON_SCRIPT_WEB" "$PID_FILE_WEB" "$GUNICORN_CMD_WEB" "Web-Dienst"
        start_service "$PYTHON_SCRIPT_API" "$PID_FILE_API" "$GUNICORN_CMD_API" "API-Dienst"
    fi
    
    log_message "INFO" "Update erfolgreich abgeschlossen"
}

# Token-Generierung
generate_token() {
    if [ -x "tokenapi.sh" ]; then
        log_message "INFO" "Führe Token-Generierung aus..."
        ./tokenapi.sh
    else
        handle_error "Token-Skript nicht gefunden oder nicht ausführbar"
    fi
}

# Hauptlogik
main() {
    check_requirements

    case "$1" in
        web)
            case "$2" in
                start)
                    start_service "$PYTHON_SCRIPT_WEB" "$PID_FILE_WEB" "$GUNICORN_CMD_WEB" "Web-Dienst"
                    ;;
                stop)
                    stop_service "$PID_FILE_WEB" "Web-Dienst"
                    ;;
                status)
                    check_status "$PID_FILE_WEB" "Web-Dienst"
                    ;;
                *)
                    echo "Verwendung: $0 web {start|stop|status}"
                    exit 1
                    ;;
            esac
            ;;
        api)
            case "$2" in
                start)
                    start_service "$PYTHON_SCRIPT_API" "$PID_FILE_API" "$GUNICORN_CMD_API" "API-Dienst"
                    ;;
                stop)
                    stop_service "$PID_FILE_API" "API-Dienst"
                    ;;
                status)
                    check_status "$PID_FILE_API" "API-Dienst"
                    ;;
                token)
                    generate_token
                    ;;
                *)
                    echo "Verwendung: $0 api {start|stop|status|token}"
                    exit 1
                    ;;
            esac
            ;;
        update)
            case "$2" in
                perform)
                    perform_update
                    ;;
                status)
                    check_status "$PID_FILE_WEB" "Web-Dienst"
                    check_status "$PID_FILE_API" "API-Dienst"
                    ;;
                *)
                    echo "Verwendung: $0 update {perform|status}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Verwendung: $0 {web|api|update} {start|stop|status|token|perform}"
            exit 1
            ;;
    esac
}

main "$@"
exit 0