#!/usr/bin/env bash
# Genera los dos mp3 que usa [ui.sound] en herdr/config.toml a partir de los
# sonidos que trae macOS, bajados 8 dB. No se redistribuyen: son de Apple.
#
# Uso:  make-sounds.sh [dir-destino]     (default: ~/.config/herdr/sounds)
# Requiere ffmpeg (brew install ffmpeg).
set -euo pipefail

DEST="${1:-$HOME/.config/herdr/sounds}"
SRC=/System/Library/Sounds
command -v ffmpeg >/dev/null || { echo "falta ffmpeg: brew install ffmpeg" >&2; exit 1; }
mkdir -p "$DEST"

mk() {  # mk <aiff de macOS> <mp3 destino>
  ffmpeg -loglevel error -y -i "$SRC/$1" -af volume=-8dB -codec:a libmp3lame -q:a 4 "$DEST/$2"
  echo "  $DEST/$2"
}

mk Purr.aiff done-purr.mp3      # el agente termino
mk Tink.aiff request-tink.mp3   # el agente te necesita (estado "request")
