#!/bin/bash

# Logo anzeigen
cat << "EOF"
  _____                                _             _____                                                _             
 / ____|                              | |           / ____|                                              | |            
| |      ___   _ __ __   __ ___  _ __ | |_  ______ | |      ___   _ __ ___   _ __ ___    __ _  _ __    __| |  ___  _ __ 
| |     / _ \ | '_  \ \ / // _ \| '__|| __||______|| |     / _ \ | '_ ` _ \ | '_ ` _ \  / _` || '_ \  / _` | / _ \| '__|
| |____| (_) || | | |\ V /|  __/| |   | |_         | |____| (_) || | | | | || | | | | || (_| || | | || (_| ||  __/| |   
 \_____|\___/ |_| |_| \_/  \___||_|    \__|         \_____|\___/ |_| |_| |_||_| |_| |_| \__,_||_| |_| \__,_| \___||_|   
EOF

echo "Starting Convert-Commander installation..."

# Funktion zur Fortschrittsanzeige
progress_bar() {
    local progress=$1
    local total=11
    local percent=$(( progress * 100 / total ))
    local completed=$(( percent / 5 ))
    local remaining=$(( 20 - completed ))

    # Erzeuge den Fortschrittsbalken
    bar="["
    for ((i=0; i<$completed; i++)); do
        bar+="#"
    done
    for ((i=0; i<$remaining; i++)); do
        bar+=" "
    done
    bar+="] $percent%"

    # Zeige den Fortschrittsbalken an
    echo -ne "$bar\r"
    sleep 1
    if [ "$progress" -lt "$total" ]; then
        tput el
    fi
}

total_steps=11
current_step=0
INSTALL_DIR=$(pwd)

# Python installieren
echo "Installing Python..."
sudo apt-get install -y python3.6
((current_step++))
progress_bar $current_step

# pip installieren
echo "Installing pip..."
sudo apt install -y python3-pip
((current_step++))
progress_bar $current_step

# Virtuelle Umgebung einrichten
echo "Setting up virtual environment..."
python3 -m venv venv
source venv/bin/activate
((current_step++))
progress_bar $current_step

# Flask installieren
echo "Installing Flask..."
pip install flask
((current_step++))
progress_bar $current_step

# API-Flask installieren
echo "Installing API-Flask..."
pip install apiflask 
pip install flask-cors

((current_step++))
progress_bar $current_step

# Swagger UI installieren
pip install flask-swagger-ui 
((current_step++))
progress_bar $current_step

# LibreOffice installieren
echo "Installing LibreOffice..."
sudo apt-get install -y libreoffice
((current_step++))
progress_bar $current_step

# PyOO installieren
echo "Installing pyoo..."
pip install pyoo 
((current_step++))
progress_bar $current_step

# gunicorn installieren
echo "Installing gunicorn..."
pip install gunicorn
((current_step++))
progress_bar $current_step

# jp installieren
echo "Installing jp..."
sudo apt-get install jq
((current_step++))
progress_bar $current_step


# Ordner erstellen
echo "Creating folders..."
mkdir -p ./convert ./uploads
((current_step++))
progress_bar $current_step

# Start-Skript ausführbar machen
echo "Setting executable permission for start.sh..."
chmod +x start.sh

# Alias in ~/.bash_aliases hinzufügen
echo "Creating alias for Convert-Commander..."
echo "alias ccommander='$INSTALL_DIR/start.sh'" >> ~/.bash_aliases

# ~/.bash_aliases laden, um den Alias sofort verfügbar zu machen
source ~/.bash_aliases

# Bash-Completion für ccommander hinzufügen
echo "Adding Bash completion for ccommander..."
cat << 'EOF' >> ~/.bashrc

# Bash Completion für ccommander
_ccommander_completion() {
    local cur prev options
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    options="web api"  # Erste Ebene der Optionen

    case "$prev" in
        ccommander)
            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
            ;;
        web|api)
            COMPREPLY=( $(compgen -W "start stop status token" -- "$cur") )
            ;;
    esac
    return 0
}

# Bash Completion für den Alias ccommander aktivieren
complete -F _ccommander_completion ccommander
EOF

# ~/.bashrc neu laden, um die Änderungen sofort anzuwenden
source ~/.bashrc

echo "Alias 'ccommander' with auto-completion has been set up. You can now use 'ccommander' from any directory."

# Fertigstellung anzeigen
echo -e "\nConvert-Commander installation completed successfully!"
