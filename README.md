# Deepy Website

Static website for `deepy.kirineko.tech`.

## Local Preview

```bash
docker compose up --build
```

Open `http://localhost:18080`.

## Screenshot Asset

The UI preview uses `assets/deepy-ui.webp`.

## Installer Paths

- `/install.sh`
- `/install.ps1`
- `/install-zh.sh`
- `/install-zh.ps1`

The `zh` installers use the Tsinghua PyPI mirror only for the current
`uv tool install` command. They do not write `uv.toml`, `pip.conf`, or persistent
Python package-manager configuration.
