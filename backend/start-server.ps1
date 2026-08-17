$nodePath = "D:\Program Files\DevEco Studio\tools\node\node.exe"
$serverPath = Join-Path $PSScriptRoot "server.js"

if (Test-Path $nodePath) {
  & $nodePath $serverPath
} else {
  node $serverPath
}
