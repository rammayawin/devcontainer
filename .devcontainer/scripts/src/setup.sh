#!/bin/bash

setup_credentials() {
  # Create the .env file for sfcc-storefront
  grep -E 'INSTANCEURL|INSTANCENAME|CLIENTID|CLIENTSECRET' $CONFIG_FILE > $DATA_DIR/.env

  # Create/update the dw.json
  if [ ! -d $VSC_DIR ]; then
    mkdir $VSC_DIR
  fi
  echo '{"hostname":"'$INSTANCEURL'","username":"'$DW_USERNAME'","password":"'${INSTANCE_WEBDAV_ACCESS_KEY/"/"/"\/"}'","code-version":"'$CODE_VERSION'"}' | jq . > $VSC_DIR/dw.json
}

setup_prophet_debugger() {
  # Create/update the launch.json
  echo '{"version":"0.1.0","configurations":[{"type":"prophet","request":"launch","name":"Attach to Sandbox"}]}' | jq . > $VSC_DIR/launch.json
}