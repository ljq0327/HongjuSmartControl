$nodePath = "D:\Program Files\DevEco Studio\tools\node\node.exe"
$hvigorPath = "D:\Program Files\DevEco Studio\tools\hvigor\bin\hvigorw.js"
$sdkRoot = "D:\Program Files\DevEco Studio\sdk"

if (!(Test-Path $nodePath)) {
  Write-Error "未找到 DevEco Node: $nodePath"
  exit 1
}

if (!(Test-Path $hvigorPath)) {
  Write-Error "未找到 hvigor: $hvigorPath"
  exit 1
}

if (!(Test-Path $sdkRoot)) {
  Write-Error "未找到 DevEco SDK 根目录: $sdkRoot"
  exit 1
}

$env:DEVECO_SDK_HOME = $sdkRoot

& $nodePath $hvigorPath `
  --mode module `
  -p module=entry@default `
  -p product=default `
  -p pageType=page `
  -p compileResInc=true `
  -p requiredDeviceType=phone `
  -p previewMode=true `
  -p buildRoot=.preview `
  PreviewBuild `
  --watch `
  --analyze=normal `
  --parallel `
  --incremental `
  --daemon
