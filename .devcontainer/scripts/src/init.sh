#!/bin/sh

CONFIG=.devcontainer/scripts/config

SKIP_BUILD=$(sed -n "s/^SKIP_BUILD=\(.*\)/\1/p" $CONFIG)
if [ -z $SKIP_BUILD ]; then
  NODE_MODULES=$(find . -name 'node_modules' -type d -prune)
  if [ ! -z $NODE_MODULES ]; then
    echo $'\n=== [START] Removing node_modules ===\n'
    for dir in $(find . -name 'node_modules' -type d -prune); do
      echo "-- $dir"
      rm -rf $dir
    done
    echo $'\n=== [ END ] Removing node_modules ===\n'
  else
    echo $'\n=== There are no existing node_modules ===\n'
  fi
else
  echo $'\n=== No need to remove node_modules ===\n'
fi

EXIST_CONTAINER=$(docker ps --filter "name=dc2-container" --quiet)
RENEW_CONTAINER=$(sed -n "s/^RENEW_CONTAINER=\(.*\)/\1/p" $CONFIG)
if [ ! [ -z $EXIST_CONTAINER && -z $RENEW_CONTAINER ] ]; then
  echo $'\n=== [START] RUN: devcontainer up --workspace-folder . --remove-existing-container ===\n'
  devcontainer up --workspace-folder . --remove-existing-container
  echo $'\n=== [ END ] RUN: devcontainer up --workspace-folder . --remove-existing-container ===\n'
else
  echo $'\n=== [START] RUN: devcontainer up --workspace-folder . ===\n'
  devcontainer up --workspace-folder .
  echo $'\n=== [ END ] RUN: devcontainer up --workspace-folder . ===\n'
fi