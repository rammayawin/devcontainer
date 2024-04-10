Set-Alias -Name find -Value C:\"Program Files"\Git\usr\bin\find.exe
Set-Alias -Name pwd -Value C:\"Program Files"\Git\usr\bin\pwd.exe
Set-Alias -Name rm -Value C:\"Program Files"\Git\usr\bin\rm.exe
Set-Alias -Name sed -Value C:\"Program Files"\Git\usr\bin\sed.exe

$CONFIG = ".devcontainer/scripts/config"

function Write-C-Host ($string, $pre) {
  if ($pre) {
    Write-Host "`n=== [$pre] $string [$(Get-Date -UFormat %T)] ===`n"
  }
  else {
    Write-Host "`n=== $string [$(Get-Date -UFormat %T)] ===`n"
  }
}

function Set-Config ($var) {
  if (sed -n "s/^$var=\\(changeme\\)/\\1/p" $CONFIG) {
    switch ($var) {
      "INSTANCEURL" { $e = "Enter your sandbox instance (bfzf-XXX)" }
      "CLIENTID" { $e = "Enter your client id" }
      "CLIENTSECRET" { $e = "Enter your client secret" }
      "DW_USERNAME" { $e = "Enter your demandware username" }
      "DW_PASSWORD" { $e = "Enter your demandware password" }
      "CODE_VERSION" { $e = "Enter your code version" }
      "INSTANCE_WEBDAV_ACCESS_KEY" { $e = "Enter your webdav access key" }
      "SOURCE_INSTANCEURL" { $e = "Enter your source instance (bfzf-XXX)" }
      "SOURCE_CLIENTID" { $e = "Enter your source client id" }
      "SOURCE_CLIENTSECRET" { $e = "Enter your source client secret" }
      default {}
    }
    
    if ($var -eq "DW_PASSWORD") {
      $ans = Read-Host $e -MaskInput
    }
    else {
      $ans = Read-Host $e
    }

    if ($ans) {
      sed -i "s/^$var=changeme/$var=$ans/" $CONFIG
      if ($var -eq "INSTANCEURL") {
        sed -i "s/^INSTANCENAME=changeme/INSTANCENAME=$ans/" $CONFIG
      }
    }
  }
}

$MAIN =  $(pwd) | sed -n "s/.*\\/\\(.*\\)$/\\1/p"
$PACKAGE = "package.json"

if (sed -n "s/\\(changeme\\)/\\1/p" $PACKAGE) {
  Write-C-Host "Renaming package name" "START"
  sed -i "s/changeme/$($MAIN.ToLower())/" $PACKAGE
  Write-C-Host "Renaming package name" " END "
}

if (sed -n "s/\\(changeme\\)/\\1/p" $CONFIG) {
  Write-C-Host "Setting config file" "START"
  Set-Config "INSTANCEURL"
  Set-Config "CLIENTID"
  Set-Config "CLIENTSECRET"
  Set-Config "DW_USERNAME"
  Set-Config "DW_PASSWORD"
  Set-Config "CODE_VERSION"
  Set-Config "INSTANCE_WEBDAV_ACCESS_KEY"
  Set-Config "SOURCE_INSTANCEURL"
  Set-Config "SOURCE_CLIENTID"
  Set-Config "SOURCE_CLIENTSECRET"
  if (sed -n "s/\\(\\/workspaces\\/changeme\\)/\\1/p" $CONFIG) {
    sed -i "s/\/workspaces\/changeme/\/workspaces\/$MAIN/" $CONFIG
  }
  Write-C-Host "Setting config file" " END "
}

$SKIP_BUILD = sed -n "s/^SKIP_BUILD=\\(.*\\)/\\1/p" $CONFIG
if (!$SKIP_BUILD) {
  $NODE_MODULES = find . -name 'node_modules' -type d -prune
  if ($NODE_MODULES) {
    Write-C-Host "Removing node_modules" "START"
    foreach ($dir in $NODE_MODULES) {
      "Removing $dir"
      rm -rf $dir
    }
    Write-C-Host "Removing node_modules" " END "
  }
  else {
    Write-C-Host "There are no existing node_modules"
  }
}
else {
  Write-C-Host "No need to remove node_modules"
}

$EXIST_CONTAINER = docker ps --filter "name=dc2-container" --quiet
$RENEW_CONTAINER = sed -n "s/^RENEW_CONTAINER=\\(.*\\)/\\1/p" $CONFIG
if ($EXIST_CONTAINER -and $RENEW_CONTAINER) {
  Write-C-Host "RUN: devcontainer up --workspace-folder . --remove-existing-container" "START"
  devcontainer up --workspace-folder . --remove-existing-container
  Write-C-Host "RUN: devcontainer up --workspace-folder . --remove-existing-container" " END "
}
else {
  Write-C-Host "RUN: devcontainer up --workspace-folder ." "START"
  devcontainer up --workspace-folder .
  Write-C-Host "RUN: devcontainer up --workspace-folder ." " END "
}