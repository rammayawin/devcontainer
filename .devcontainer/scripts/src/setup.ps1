$CONFIG = ".devcontainer/scripts/config"

$SKIP_BUILD = sed -n "s/^SKIP_BUILD=\\(.*\\)/\\1/p" $CONFIG
if (!$SKIP_BUILD) {
  $NODE_MODULES = find . -name 'node_modules' -type d -prune
  if ($NODE_MODULES) {
    "`n=== [START] Removing node_modules ===`n"
    foreach ($dir in $NODE_MODULES) {
      "Removing $dir"
      rm -rf $dir
    }
    "`n=== [ END ] Removing node_modules ===`n"
  }
  else {
    "`n=== There are no existing node_modules ===`n"
  }
}
else {
  "`n=== No need to remove node_modules ===`n"
}

$EXIST_CONTAINER = docker ps --filter "name=dc2-container" --quiet
$RENEW_CONTAINER = sed -n "s/^RENEW_CONTAINER=\\(.*\\)/\\1/p" $CONFIG
if ($EXIST_CONTAINER -and $RENEW_CONTAINER) {
  "`n=== [START] RUN: devcontainer up --workspace-folder . --remove-existing-container ===`n"
  devcontainer up --workspace-folder . --remove-existing-container
  "`n=== [ END ] RUN: devcontainer up --workspace-folder . --remove-existing-container ===`n"
}
else {
  "`n=== [START] RUN: devcontainer up --workspace-folder . ===`n"
  devcontainer up --workspace-folder .
  "`n=== [ END ] RUN: devcontainer up --workspace-folder . ===`n"
}