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

# Alias für Convert-Commander erstellen und laden
echo "Creating alias for Convert-Commander..."
echo "alias ccommander='./start.sh'" >> ~/.bash_aliases
source ~/.bash_aliases

# Bash-Completion für ccommander erstellen
echo "Setting up bash completion for ccommander..."
sudo mkdir -p /etc/bash_completion.d

# Completion-Skript erstellen
sudo tee /etc/bash_completion.d/ccommander-completion.bash > /dev/null << 'EOF'
_ccommander_completion() {
    local cur prev opts sub_opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Hauptoptionen
    opts="web api"

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
        "ccommander")
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
    esac
}

complete -F _ccommander_completion ccommander
EOF

# Completion-Skript ausführbar machen und aktivieren
sudo chmod +x /etc/bash_completion.d/ccommander-completion.bash
source /etc/bash_completion.d/ccommander-completion.bash

echo "Installation completed. Bash completion for ccommander is now active."

# Fertigstellung anzeigen
echo -e "\nConvert-Commander installation completed successfully!"
