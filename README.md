# selly-installer

Installations-Skripte für **sellyApps** unter Linux via Wine. Erzeugt einen sauberen Wine-Prefix in `~/Selly`, installiert sellyApps, und registriert den `sellyapps://` URI-Handler systemweit.

## Was es macht

1. Stellt sicher, dass Wine installiert ist (Distro-spezifisch)
2. Legt einen `win64` Wine-Prefix unter `~/Selly` an, lädt mono/gecko nach
3. Installiert `corefonts` via winetricks
4. Lädt den offiziellen sellyApps-Installer (bundelt JRE 8u412) und führt ihn aus
5. Schreibt einen `.desktop`-Eintrag und registriert `x-scheme-handler/sellyapps`

WebView2 wird **nicht** installiert — sellyApps läuft ohne.

## Voraussetzungen

- Erreichbarkeit von `selly.biz`, `dl.winehq.org` (nur Ubuntu) und `github.com` (für corefonts)
- DNS muss interne Hostnamen auflösen können falls der Proxy/Server intern liegt
- `sudo`-Rechte für die Paket-Installation

## Verwendung

### CachyOS / Arch

```bash
bash install-selly.sh
```

### Ubuntu / Zorin OS

```bash
bash install-selly-ubuntu.sh
```

Das Ubuntu-Skript fügt das offizielle **WineHQ-Repo** hinzu (Stock-Wine ist meist zu alt) und erkennt den Codename automatisch (`UBUNTU_CODENAME` aus `/etc/os-release`).

## Nach der Installation

Erst Proxy konfigurieren (falls intern):

```bash
xdg-open 'sellyapps://settings/proxy'
```

Dann normaler Aufruf — entweder direkt:

```bash
xdg-open 'sellyapps://kgo/kgo/'
```

…oder durch Klick auf einen `sellyapps://`-Link im Browser.

## Idempotenz

Alle Skripte sind sicher mehrfach ausführbar:

- Wine wird nur installiert wenn nicht vorhanden
- Prefix wird nur initialisiert wenn `~/Selly/drive_c` fehlt
- Installer wird nur erneut runtergeladen wenn die Datei fehlt
- Installer-Run wird übersprungen wenn `sellyApps.exe` schon im Prefix liegt

## Konfiguration

Variablen oben in den Skripten:

| Variable | Default | Zweck |
|---|---|---|
| `PREFIX` | `~/Selly` | Wine-Prefix-Pfad |
| `INSTALLER_URL` | aktuelle SMC-Build von selly.biz | sellyApps-Installer |
| `WINEARCH` | `win64` | Prefix-Architektur |
