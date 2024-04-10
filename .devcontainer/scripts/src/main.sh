#!/bin/bash

if [ ! -d $TMP_DIR ]; then
  mkdir $TMP_DIR
fi

sfcc_build_deploy() {
  if sfcc_build; then
    echo "=== Successfully built the cartridges ==="
    if sfcc_deploy; then
      echo "=== Successfully deployed the cartridges ==="
      return 0
    else
      echo "=== Failed the deployment of the cartridges ==="
      return 1
    fi
  else
    return 1
  fi
}

sfcc_build() {
  if [ ! -z $SKIP_BUILD ]; then
    echo "=== Skip building the cartridges ==="
    return 0
  fi

  # Go to the webpack builder directory
  # Install the dependencies
  cd $STOREFRONT_DIR/sfra-webpack-builder
  echo "=== Installing $STOREFRONT_DIR/sfra-webpack-builder ==="
  if ! npm install; then
    echo "=== Installation of dependencies failed. Exiting... ==="
    return 1
  fi

  # Install the cartridges
  echo "=== Starting the cartridge installation ==="
  if ! npm run npmInstall; then
    echo "=== Installation of cartridges failed. Exiting... ==="
    return 1
  fi

  # Build the storefront
  if ! npm run dev; then
    echo "=== Building the storefront failed. Exiting... ==="
    return 1
  fi

  build_cartridges "$STOREFRONT_DIR/sfra_optus_au"
  build_cartridges "$CORE_DIR/storefront-reference-architecture"
  build_cartridges "$CORE_DIR/sfra_optus_core"

  echo "=== Zipping it up ==="
  zip -r -q optus_sfcc_core.zip $TMP_DIR/optus_sfcc_core

  sed -i "s/SKIP_BUILD=/SKIP_BUILD=true/" $CONFIG_FILE
}

build_cartridges() {
  local dir=$1
  echo "=== Installing $dir ==="

  cd $dir

  if ! npm install; then
    echo "=== Installation of dependencies failed. Exiting... ==="
    exit 1
  fi

  cp -R cartridges/* $TMP_DIR/optus_sfcc_core
}

sfcc_deploy() {
  if [ ! -z $SKIP_DEPLOY ]; then
    return 0
  fi

  sfcc-ci client:auth "$CLIENTID" "$CLIENTSECRET" -a account.demandware.com

  if [ $? -ne 0 ]; then
    echo "=== SFCC Authentication failed ==="
    return 1
  fi

  echo "=== Starting upload to $INSTANCEURL ==="
  sfcc-ci code:deploy optus_sfcc_core.zip -i "$INSTANCEURL"
  if [ $? -ne 0 ]; then
    echo "=== sfcc-ci deploy failed ==="
    return 1
  fi

  sed -i "s/SKIP_DEPLOY=/SKIP_DEPLOY=true/" $CONFIG_FILE
}

sfcc_data_import() {
  if [ -z $SKIP_DATA_IMPORT ]; then
    cd $DATA_DIR

    if ! npm install; then
      echo "=== Installation of dependencies failed ==="
      return 1
    fi

    if ! npm run zipOptusData; then
      echo "=== Creation of the data zip has failed ==="
      return 1
    fi

    if ! npm run zipOptusSampleData; then
      echo "=== Creation of the sample data zip has failed ==="
      return 1
    fi

    echo "=== Running data import ==="
    if ! npm run importData; then
      echo "=== Data import has failed ==="
      return 1
    fi

    sed -i "s/SKIP_DATA_IMPORT=/SKIP_DATA_IMPORT=true/" $CONFIG_FILE
  fi

  return 0
}

sfcc_data_reindex_rebuild() {
  cd $DATA_DIR

  if ! npm run data:reindex; then
    echo "=== Data reindexing failed ==="
    return 1
  fi

  if ! npm run data:rebuild; then
    echo "=== URL rebuild failed ==="
    return 1
  fi

  return 0
}

cleanup() {
  rm -rf $TMP_DIR
}