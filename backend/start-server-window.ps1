$nodePath = "D:\Program Files\DevEco Studio\tools\node\node.exe"
$serverPath = Join-Path $PSScriptRoot "server.js"

if (Test-Path $nodePath) {
  Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "& '$nodePath' '$serverPath'"
  )
} else {
  Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "node '$serverPath'"
  )
}
