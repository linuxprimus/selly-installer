#!/usr/bin/env bash
set -euo pipefail

# --- Konfiguration -----------------------------------------------------------
PREFIX="$HOME/Selly"
INSTALLER_URL="https://www.selly.biz/downloads/sellyapps/sellyappswinx86.2.5.5.8612.SMC.8u412.exe"
INSTALLER="$HOME/Downloads/$(basename "$INSTALLER_URL")"
APP_EXE="$HOME/Selly/drive_c/Program Files (x86)/sellysolutions/sellyApps/sellyApps.exe"
DESKTOP_NAME="sellyapps.desktop"
DESKTOP_FILE="$HOME/.local/share/applications/$DESKTOP_NAME"
URI_SCHEME="x-scheme-handler/sellyapps"

export WINEPREFIX="$PREFIX"
export WINEARCH="win64"
export WINEDEBUG="${WINEDEBUG:--all}"

log() { printf '\n>> %s\n' "$*"; }

# --- 1. Wine sicherstellen (CachyOS / Arch) ----------------------------------
if ! command -v wine >/dev/null 2>&1; then
  log "wine ist nicht installiert – installiere via pacman"
  sudo pacman -S --needed --noconfirm wine winetricks
fi

# --- 2. Prefix anlegen + Abhängigkeiten --------------------------------------
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
  log "starte Installer – folge dem Setup-Assistenten"
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
Exec=env WINEPREFIX="$PREFIX" wine "$APP_EXE" %u
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
echo "   Test:     xdg-open 'sellyapps://kgo/kgo/'"
