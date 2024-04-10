#!/bin/bash

echo $'\n=== [START] POST Create Command ===\n'

for src in $SRC_DIR/main.sh $SRC_DIR/setup.sh $SRC_DIR/sfcc-org-migration.sh; do
    source $src
done

echo $'\n=== [START] Setting up the credentials ===\n'
if ! setup_credentials; then
    echo "[ERROR] Setting up the credentials. Exiting..."
    cleanup
    exit 1
fi
echo $'\n=== [ END ] Setting up the credentials ===\n'

# launch.json doesn't seem to be created by Prophet Debugger
setup_prophet_debugger

# SFCC Build and Deploy
echo $'\n=== [START] SFCC build and deploy local environment ===\n'
if ! sfcc_build_deploy; then
    echo "[ERROR] SFCC build and deploy local environment failed. Exiting..."
    cleanup
    exit 1
fi
echo $'\n=== [ END ] SFCC build and deploy local environment ===\n'

# SFCC Data Import
echo $'\n=== [START] SFCC data import local environment ===\n'
if ! sfcc_data_import; then
    echo "[ERROR] SFCC data import failed. Exiting..."
    cleanup
    exit 1
fi
echo $'\n=== [ END ] SFCC data import local environment ===\n'

# SFCC Org Migration
echo $'\n=== [START] SFCC org migration ===\n'
if ! sfcc_org_migration; then
    echo "[ERROR] SFCC org migration. Exiting..."
    cleanup
    exit 1
fi
echo $'\n=== [ END ] SFCC org migration ===\n'

# SFCC Data Reindex and Rebuild
echo $'\n=== [START] SFCC data reindex and rebuild ===\n'
if ! sfcc_data_reindex_rebuild; then
    echo "[ERROR] SFCC reindex and rebuild. Exiting..."
    cleanup
    exit 1
fi
echo $'\n=== [ END ] SFCC reindex and rebuild ===\n'

# Cleanup
cleanup

echo $'\n=== [ END ] POST Create Command ===\n'