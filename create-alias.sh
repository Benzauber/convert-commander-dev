#!/bin/bash

# Ursprüngliches Setup-Skript aktualisieren
sudo tee /etc/bash_completion.d/ccommander-completion.bash > /dev/null << 'EOF'
_ccommander_completion() {
    local cur prev opts sub_opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Hauptoptionen (update hinzugefügt)
    opts="web api update"
    
    # Unteroptionen basierend auf dem ersten Argument
    case "${prev}" in
        "web")
            sub_opts="start stop status"
            COMPREPLY=( $(compgen -W "${sub_opts}" -- ${cur}) )
            return 0
            ;;
        "api")
            sub_opts="start stop status token"
            COMPREPLY=( $(compgen -W "${sub_opts}" -- ${cur}) )
            return 0
            ;;
        "update")
            sub_opts="check perform"
            COMPREPLY=( $(compgen -W "${sub_opts}" -- ${cur}) )
            return 0
            ;;
        "ccommander")
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
    esac
}

complete -F _ccommander_completion ccommander
EOF

# Update-Skript erstellen
sudo tee update.sh > /dev/null << 'EOF'
#!/bin/bash

# Funktion für Fehlerbehandlung
handle_error() {
    echo "Fehler: $1"
    exit 1
}

# Funktion zum Prüfen der Internetverbindung
check_connection() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        handle_error "Keine Internetverbindung verfügbar"
    fi
}

# Funktion zum Backup erstellen
create_backup() {
    echo "Erstelle Backup..."
    backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir" || handle_error "Backup-Verzeichnis konnte nicht erstellt werden"
    cp -r * "$backup_dir/" 2>/dev/null || echo "Warnung: Einige Dateien konnten nicht kopiert werden"
    echo "Backup erstellt in: $backup_dir"
}

# Hauptfunktion für Updates
perform_update() {
    echo "Starte Update-Prozess..."
    
    # Prüfe Internetverbindung
    check_connection
    
    # Erstelle Backup
    create_backup
    
    # Führe Updates durch
    echo "Aktualisiere Pakete..."
    sudo apt-get update || handle_error "apt-get update fehlgeschlagen"
    sudo apt-get upgrade -y || handle_error "apt-get upgrade fehlgeschlagen"
    
    # Aktualisiere Python-Pakete falls requirements.txt existiert
    if [ -f "requirements.txt" ]; then
        echo "Aktualisiere Python-Pakete..."
        pip install -r requirements.txt --upgrade || handle_error "Python-Paket-Update fehlgeschlagen"
    fi
    
    echo "Update erfolgreich abgeschlossen!"
}

# Funktion zum Prüfen auf verfügbare Updates
check_updates() {
    echo "Prüfe auf verfügbare Updates..."
    check_connection
    
    sudo apt-get update &>/dev/null || handle_error "apt-get update fehlgeschlagen"
    updates=$(sudo apt-get -s upgrade | grep -P '^\d+ upgraded' | cut -d" " -f1)
    
    if [ -f "requirements.txt" ]; then
        echo "Verfügbare System-Updates: $updates"
        echo "Python-Paket-Status:"
        pip list --outdated
    else
        echo "Verfügbare System-Updates: $updates"
        echo "Keine requirements.txt gefunden - Python-Pakete werden übersprungen"
    fi
}

# Hauptprogramm
case "$1" in
    "check")
        check_updates
        ;;
    "perform")
        perform_update
        ;;
    *)
        echo "Verwendung: $0 {check|perform}"
        echo "  check   - Prüft auf verfügbare Updates"
        echo "  perform - Führt das Update durch"
        exit 1
        ;;
esac
EOF

# Mache Update-Skript ausführbar
chmod +x update.sh

# Aktualisiere Bash-Completion
source /etc/bash_completion.d/ccommander-completion.bash

echo "Update-Skript wurde erstellt und Bash-Completion wurde aktualisiert."