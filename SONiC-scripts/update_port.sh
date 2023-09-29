#!/bin/bash

# By default, simulate changes without writing to any file
SIMULATE=true
CONFIG_FILE="/etc/sonic/config_db.json"
usage() {
    echo "Usage: $0 [-r|--really-run] -p <port_number> -a <alias> -c <config file"
    echo "  -r, --really-run    Modify the real config at /etc/sonic/config_db.json. Without this option, the script only simulates the changes."
    echo "  -p                  Specify the port number (e.g., 0 for Ethernet0)"
    echo "  -a                  Specify the alias to set for the port"
    echo "  -c                  Specify an alternate config file (default: $CONFIG_FILE)"
    exit 1
}

# Parse command-line arguments
while getopts ":rp:a:c:" opt; do
  case $opt in
    r) SIMULATE=false ;;
    p) INDEX="$OPTARG" ;;
    a) ALIAS="$OPTARG" ;;
    c) CONFIG_FILE="$OPTARG" ;;
    \?) 
       # Capture --really-run
       if [ "$OPTARG" == "really-run" ]; then
           SIMULATE=false
       else
           echo "Invalid option -$OPTARG" >&2
           usage
       fi
       ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done

# Ensure both PORT and ALIAS are provided
if [ -z "$INDEX" ] || [ -z "$ALIAS" ]; then
    echo "Both -p and -a arguments must be specified."
    usage
fi

# Use jq to create a modified configuration (simulation or real modification)
PORT="Ethernet"$(jq -r --arg idx "$INDEX" '.PORT | to_entries[] | select(.value.index == $idx) | .key | ltrimstr("Ethernet")' "$CONFIG_FILE")
MODIFIED_CONFIG=$(jq --arg port "$PORT" --arg alias "$ALIAS" '.PORT[$port].alias = $alias' "$CONFIG_FILE")
if [ "$SIMULATE" == "true" ]; then
    echo "Simulated changes for $CONFIG_FILE:"
    echo "$MODIFIED_CONFIG" | jq --arg port "$PORT" '.PORT[$port]'
else
    # Backup current config
    CONFIG_FILENAME=$(basename $CONFIG_FILE)
    BACKUP_FILE="$PWD/${CONFIG_FILENAME}.$(date +'%Y%m%d-%H%M%S').bak"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Config file backed up to $BACKUP_FILE"
    # Write the modified configuration back to the config file
    echo "$MODIFIED_CONFIG" | sudo tee "$CONFIG_FILE" >/dev/null
    echo "Alias for $PORT set to $ALIAS in $CONFIG_FILE"
    # Retrieve and display the settings for the modified port
    PORT_SETTINGS=$(jq --arg port "$PORT" '.PORT[$port]' "$CONFIG_FILE")
    echo "Current settings for $PORT:"
    echo "$PORT_SETTINGS"
fi

