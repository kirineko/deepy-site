#!/usr/bin/env bash
set -euo pipefail

info() {
  printf '[deepy] %s\n' "$1"
}

add_path_entry() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

refresh_uv_path() {
  if [ -n "${UV_INSTALL_DIR:-}" ] && [ -d "$UV_INSTALL_DIR" ]; then
    add_path_entry "$UV_INSTALL_DIR"
  fi

  if [ -d "$HOME/.local/bin" ]; then
    add_path_entry "$HOME/.local/bin"
  fi

  if [ -d "$HOME/.cargo/bin" ]; then
    add_path_entry "$HOME/.cargo/bin"
  fi
}

find_uv() {
  refresh_uv_path

  if command -v uv >/dev/null 2>&1; then
    command -v uv
    return
  fi

  if [ -x "$HOME/.local/bin/uv" ]; then
    printf '%s\n' "$HOME/.local/bin/uv"
    return
  fi

  if [ -x "$HOME/.cargo/bin/uv" ]; then
    printf '%s\n' "$HOME/.cargo/bin/uv"
  fi
}

install_uv() {
  info "Installing uv."

  if command -v curl >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_PROGRESS=1 sh >/dev/null
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO- https://astral.sh/uv/install.sh | env UV_NO_PROGRESS=1 sh >/dev/null
    return
  fi

  printf '[deepy] Error: curl or wget is required to install uv.\n' >&2
  exit 1
}

UV_BIN="$(find_uv || true)"
if [ -n "$UV_BIN" ]; then
  :
else
  install_uv
  UV_BIN="$(find_uv || true)"
  if [ -z "$UV_BIN" ]; then
    printf '[deepy] Error: uv not found after installation. Restart your shell and try again.\n' >&2
    exit 1
  fi
fi

info "Installing Deepy."
"$UV_BIN" tool install --python 3.13 deepy-cli
info "Done."
