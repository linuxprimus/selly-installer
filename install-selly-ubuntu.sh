#!/usr/bin/env bash
set -euo pipefail

# --- Konfiguration -----------------------------------------------------------
PREFIX="$HOME/Selly"
INSTALLER_URL="https://www.selly.biz/downloads/sellyapps/sellyappswinx86.2.5.5.8612.SMC.8u412.exe"
INSTALLER="$HOME/Downloads/$(basename "$INSTALLER_URL")"
APP_EXE="$PREFIX/drive_c/Program Files (x86)/sellysolutions/sellyApps/sellyApps.exe"
DESKTOP_NAME="sellyapps.desktop"
DESKTOP_FILE="$HOME/.local/share/applications/$DESKTOP_NAME"
URI_SCHEME="x-scheme-handler/sellyapps"

export WINEPREFIX="$PREFIX"
export WINEARCH="win64"
export WINEDEBUG="${WINEDEBUG:--all}"

log() { printf '\n>> %s\n' "$*"; }

# --- 1. Wine sicherstellen (Ubuntu / Zorin via WineHQ-Repo) ------------------
if ! command -v wine >/dev/null 2>&1; then
  log "wine ist nicht installiert – installiere via WineHQ-Repo"

  # Ubuntu-Codename ermitteln (Zorin liefert ihn in UBUNTU_CODENAME)
  . /etc/os-release
  CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
  if [ -z "$CODENAME" ]; then
    echo "!! Konnte Ubuntu-Codename nicht ermitteln. Setze CODENAME=jammy als Fallback."
    CODENAME="jammy"
  fi
  echo "   verwende WineHQ-Quelle für: $CODENAME"

  sudo dpkg --add-architecture i386
  sudo mkdir -pm755 /etc/apt/keyrings
  sudo wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
  sudo wget -qNP /etc/apt/sources.list.d/ \
    "https://dl.winehq.org/wine-builds/ubuntu/dists/$CODENAME/winehq-$CODENAME.sources"
  sudo apt update
  sudo apt install -y --install-recommends winehq-stable winetricks cabextract curl
fi

# --- 2. Prefix anlegen + Fonts -----------------------------------------------
if [ ! -d "$PREFIX/drive_c" ]; then
  log "lege Wine-Prefix an: $PREFIX  (mono/gecko werden automatisch geladen)"
  wineboot -i

  log "installiere Fonts via winetricks"
  winetricks -q corefonts
fi

# --- 3. Installer laden + ausführen ------------------------------------------
mkdir -p "$HOME/Downloads"
if [ ! -f "$INSTALLER" ]; then
  log "lade sellyApps-Installer"
  curl -fL "$INSTALLER_URL" -o "$INSTALLER"
fi

if [ ! -f "$APP_EXE" ]; then
  log "starte Installer (läuft in der Regel silent durch)"
  wine "$INSTALLER"
else
  log "sellyApps ist bereits im Prefix installiert – überspringe Installer"
fi

# --- 4. Desktop-Eintrag + URI-Handler ----------------------------------------
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=SellyApps
Exec=env WINEPREFIX=$PREFIX wine "$APP_EXE" %u
Terminal=false
StartupNotify=true
NoDisplay=true
MimeType=$URI_SCHEME;
Categories=Network;
EOF

update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
xdg-mime default "$DESKTOP_NAME" "$URI_SCHEME"

log "fertig."
echo "   Prefix:   $PREFIX"
echo "   Test:     xdg-open 'sellyapps://settings/proxy'"
echo "   Danach:   xdg-open 'sellyapps://kgo/kgo/'"
