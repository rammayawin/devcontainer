#!/bin/bash

echo $'\n=== [START] POST Start Command ===\n'

source $SRC_DIR/setup.sh

echo $'\n=== [START] Setting up the credentials ===\n'
if ! setup_credentials; then
    echo "[ERROR] Setting up the credentials. Exiting..."
    exit 1
fi
echo $'\n=== [ END ] Setting up the credentials ===\n'

# launch.json doesn't seem to be created by Prophet Debugger
setup_prophet_debugger

echo $'\n=== [ END ] POST Start Command ===\n'