#!/usr/bin/env bash
set -euo pipefail

info() {
  printf '[deepy] %s\n' "$1"
}

install_uv() {
  info "uv not found; installing uv with the upstream installer."

  if command -v curl >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO- https://astral.sh/uv/install.sh | sh
    return
  fi

  printf '[deepy] Error: curl or wget is required to install uv.\n' >&2
  exit 1
}

if command -v uv >/dev/null 2>&1; then
  UV_BIN="uv"
  info "Using existing uv command."
else
  install_uv
  if command -v uv >/dev/null 2>&1; then
    UV_BIN="uv"
  elif [ -x "$HOME/.local/bin/uv" ]; then
    UV_BIN="$HOME/.local/bin/uv"
  else
    printf '[deepy] Error: uv not found after installation. Restart your shell and try again.\n' >&2
    exit 1
  fi
fi

info "Installing Deepy with Python 3.13."
"$UV_BIN" tool install --python 3.13 deepy-cli
info "Done. Run 'deepy --version' to verify the installation."
