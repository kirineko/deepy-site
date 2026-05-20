$ErrorActionPreference = "Stop"

$TunaIndex = "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple/"

function Write-DeepyInfo {
  param([string]$Message)
  Write-Host "[deepy] $Message"
}

function Install-Uv {
  Write-DeepyInfo "uv not found; installing uv with the upstream installer."
  Invoke-RestMethod -Uri "https://astral.sh/uv/install.ps1" | Invoke-Expression
}

$uvCommand = Get-Command uv -ErrorAction SilentlyContinue
if ($uvCommand) {
  $uvBin = $uvCommand.Source
  Write-DeepyInfo "Using existing uv command."
} else {
  Install-Uv
  $uvCommand = Get-Command uv -ErrorAction SilentlyContinue
  if ($uvCommand) {
    $uvBin = $uvCommand.Source
  } else {
    $localUv = Join-Path $HOME ".local\bin\uv.exe"
    if (Test-Path $localUv) {
      $uvBin = $localUv
    } else {
      Write-Error "Error: uv not found after installation. Restart PowerShell and try again."
      exit 1
    }
  }
}

Write-DeepyInfo "Installing Deepy with Python 3.13 using the Tsinghua PyPI mirror for this command only."
Write-DeepyInfo "This script does not modify uv.toml, pip.conf, or persistent Python tooling configuration."
& $uvBin tool install --python 3.13 deepy-cli --default-index $TunaIndex
Write-DeepyInfo "Done. Run 'deepy --version' to verify the installation."
