#!/usr/bin/env bash
# One-liner Wrapper: erkennt die Distro und ruft das passende Skript auf.
# Nutzung:  curl -fsSL https://t1p.de/<slug> | bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/linuxprimus/selly-installer/main"

[ -f /etc/os-release ] || { echo "Kein /etc/os-release gefunden" >&2; exit 1; }
. /etc/os-release

case " $ID ${ID_LIKE:-} " in
  *" arch "*|*" cachyos "*|*" manjaro "*|*" endeavouros "*)
    SCRIPT="install-selly.sh" ;;
  *" ubuntu "*|*" debian "*|*" zorin "*|*" pop "*|*" linuxmint "*|*" elementary "*)
    SCRIPT="install-selly-ubuntu.sh" ;;
  *)
    echo "Unbekannte Distro: ID=$ID ID_LIKE=${ID_LIKE:-}" >&2
    echo "Unterstützt: Arch/CachyOS/Manjaro und Ubuntu/Debian/Zorin/Pop/Mint" >&2
    exit 1 ;;
esac

echo ">> Distro: ${PRETTY_NAME:-$ID}  →  führe $SCRIPT aus"
curl -fsSL "$REPO_RAW/$SCRIPT" | bash
