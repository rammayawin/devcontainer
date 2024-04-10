#!/bin/bash

sfcc_org_migration() {
  if [[ ! -z $SKIP_ORG_MIGRATION ]]; then
    return 0
  fi

  SOURCE_INSTANCE=$(echo $SOURCE_INSTANCEURL | awk -F '.' '{print $1}')

  # Login to source instance
  echo $'\n=== ['$SOURCE_INSTANCE$'] Logging in to source instance... ===\n'
  if [[ -z $SOURCE_CLIENTID || -z $SOURCE_CLIENTSECRET ]]; then
    sfcc-ci client:auth $CLIENTID $CLIENTSECRET -a account.demandware.com
  else
    sfcc-ci client:auth $SOURCE_CLIENTID $SOURCE_CLIENTSECRET -a account.demandware.com
  fi

  if [[ "$?" -ne 0 ]] ; then
    echo $'\n=== ['$SOURCE_INSTANCE$'] Client authentication has failed. Please check the client ID permissions for OCAPI and WebDAV. ===\n'
    return 1
  fi
  echo $'\n=== ['$SOURCE_INSTANCE$'] Successfully logged in. ===\n'

  DATE=$(date '+%Y%m%d')
  ZIP_FILE="$SOURCE_INSTANCE-data-$DATE-1"

  # Export data from source instance
  echo $'\n=== ['$SOURCE_INSTANCE$'] Extracting data... ===\n'
  sfcc-ci instance:export -i $SOURCE_INSTANCEURL -d '{"libraries":{"all":true},"library_static_resources":{"all":true},"catalogs":{"all":true},"inventory_lists":{"all":true},"price_books":{"all":true}}' -f $ZIP_FILE.zip -s -j
  if [[ "$?" -ne 0 ]] ; then
    echo $'\n=== ['$SOURCE_INSTANCE$'] Exporting of data has failed. ===\n'
    return 1
  fi
  echo $'\n=== ['$SOURCE_INSTANCE$'] '$ZIP_FILE$'.zip extracted. ===\n'

  # Download exported zip file
  echo $'\n=== ['$SOURCE_INSTANCE$'] Downloading data... ===\n'
  wget --user "$DW_USERNAME" --password "$DW_PASSWORD" https://$SOURCE_INSTANCEURL/on/demandware.servlet/webdav/Sites/Impex/src/instance/$ZIP_FILE.zip
  if [[ "$?" -ne 0 ]] ; then
    echo $'\n=== ['$SOURCE_INSTANCE$'] Downloading of exported file has failed. You may need to be in the Optus VPN or Optus WiFi due to IP whitelisting. ===\n'
    return 1
  fi
  echo $'\n=== ['$SOURCE_INSTANCE'] '$ZIP_FILE$'.zip downloaded. ===\n'

  echo $'\n=== ['$SOURCE_INSTANCE'] Unzipping '$ZIP_FILE$'.zip... ===\n'
  unzip $ZIP_FILE.zip

  echo $'\n=== ['$SOURCE_INSTANCE'] Changing directory to '$ZIP_FILE$' ===\n'
  cd $ZIP_FILE

  TARGET_INSTANCE=$(echo $INSTANCEURL | awk -F '.' '{print $1}')

  echo $'\n=== ['$TARGET_INSTANCE$'] Logging in to target instance... ===\n'
  sfcc-ci client:auth $CLIENTID $CLIENTSECRET -a account.demandware.com
  if [[ "$?" -ne 0 ]] ; then
    echo $'\n=== ['$TARGET_INSTANCE$'] Client authentication has failed. Please check the client ID permissions for OCAPI and WebDAV. ===\n'
    rm -rf $ZIP_FILE*
    return 1
  fi
  echo $'\n=== ['$TARGET_INSTANCE$'] Successfully logged in. ===\n'

  cd ..
  echo $'\n=== ['$TARGET_INSTANCE'] Uploading '$ZIP_FILE$'.zip... ===\n'
  sfcc-ci instance:upload $ZIP_FILE.zip -i $INSTANCEURL
  if [[ "$?" -ne 0 ]] ; then
      echo $'\n=== ['$TARGET_INSTANCE'] Upload of '$ZIP_FILE$'.zip to target instance has failed. ===\n'
      rm -rf $ZIP_FILE*
      return 1
  fi
  echo $'\n=== ['$TARGET_INSTANCE'] '$ZIP_FILE$'.zip uploaded. ===\n'

  echo $'\n=== ['$TARGET_INSTANCE'] Importing '$ZIP_FILE$'.zip... ===\n'
  echo $'\n=== [RUN] sfcc-ci instance:import '$ZIP_FILE'.zip -i '$INSTANCEURL$' -s ===\n'
  sfcc-ci instance:import $ZIP_FILE.zip -i $INSTANCEURL -s
  if [[ "$?" -ne 0 ]] ; then
    echo $'\n=== ['$TARGET_INSTANCE'] Import of '$ZIP_FILE$'.zip has failed. ===\n'
    rm -rf $ZIP_FILE*
    return 1
  fi
  echo $'\n=== ['$TARGET_INSTANCE'] '$ZIP_FILE$'.zip imported. ===\n'

  # Clean up
  rm -rf $ZIP_FILE*
}