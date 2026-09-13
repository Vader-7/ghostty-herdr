#!/usr/bin/env bash
# Builds the two mp3s used by [ui.sound] in herdr/config.toml from the sounds
# macOS ships, lowered 8 dB. They are not in the repo: they belong to Apple.
#
# Usage:  make-sounds.sh [dest-dir]     (default: ~/.config/herdr/sounds)
# Needs ffmpeg (brew install ffmpeg).
set -euo pipefail

DEST="${1:-$HOME/.config/herdr/sounds}"
SRC=/System/Library/Sounds
command -v ffmpeg >/dev/null || { echo "ffmpeg missing: brew install ffmpeg" >&2; exit 1; }
mkdir -p "$DEST"

mk() {  # mk <macOS aiff> <target mp3>
  ffmpeg -loglevel error -y -i "$SRC/$1" -af volume=-8dB -codec:a libmp3lame -q:a 4 "$DEST/$2"
  echo "  $DEST/$2"
}

mk Purr.aiff done-purr.mp3      # the agent finished
mk Tink.aiff request-tink.mp3   # the agent needs you ("request" state)
