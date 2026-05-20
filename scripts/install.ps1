$ErrorActionPreference = "Stop"

function Write-DeepyInfo {
  param([string]$Message)
  Write-Host "[deepy] $Message"
}

function Add-PathEntry {
  param([string]$PathEntry)

  if ([string]::IsNullOrWhiteSpace($PathEntry) -or -not (Test-Path -LiteralPath $PathEntry -PathType Container)) {
    return
  }

  $separator = [System.IO.Path]::PathSeparator
  $entries = $env:Path -split [regex]::Escape($separator)
  if ($entries -notcontains $PathEntry) {
    $env:Path = "$PathEntry$separator$env:Path"
  }
}

function Refresh-UvPath {
  Add-PathEntry $env:UV_INSTALL_DIR
  Add-PathEntry (Join-Path $HOME ".local\bin")

  if ($env:USERPROFILE) {
    Add-PathEntry (Join-Path $env:USERPROFILE ".local\bin")
  }
}

function Find-Uv {
  Refresh-UvPath

  $uvCommand = Get-Command uv -ErrorAction SilentlyContinue
  if ($uvCommand) {
    return $uvCommand.Source
  }

  $localUv = Join-Path $HOME ".local\bin\uv.exe"
  if (Test-Path -LiteralPath $localUv -PathType Leaf) {
    return $localUv
  }

  if ($env:USERPROFILE) {
    $profileUv = Join-Path $env:USERPROFILE ".local\bin\uv.exe"
    if (Test-Path -LiteralPath $profileUv -PathType Leaf) {
      return $profileUv
    }
  }

  return $null
}

function Install-Uv {
  Write-DeepyInfo "Installing uv."
  try {
    $env:UV_NO_PROGRESS = "1"
    $installer = Invoke-RestMethod -Uri "https://astral.sh/uv/install.ps1"
    Invoke-Expression $installer 1>$null 3>$null 4>$null 6>$null
  } catch {
    Write-Error "Error: uv installation was blocked or failed. If Windows security policy, AppLocker, Smart App Control, or antivirus blocked the downloaded script, allow scripts from deepy.kirineko.tech and astral.sh or ask an administrator to run the installer. Details: $($_.Exception.Message)"
    exit 1
  } finally {
    Remove-Item Env:\UV_NO_PROGRESS -ErrorAction SilentlyContinue
  }
}

$uvBin = Find-Uv
if (-not $uvBin) {
  Install-Uv
  $uvBin = Find-Uv
  if (-not $uvBin) {
    Write-Error "Error: uv not found after installation. Restart PowerShell and try again."
    exit 1
  }
}

Write-DeepyInfo "Installing Deepy."
& $uvBin tool install --python 3.13 deepy-cli
Write-DeepyInfo "Done."
