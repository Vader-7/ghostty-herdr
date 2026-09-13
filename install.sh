#!/usr/bin/env bash
# Copies the config into place. Never overwrites without leaving a dated .bak.
# Usage:  ./install.sh          (from the repo root)
set -euo pipefail
cd "$(dirname "$0")"

STAMP="$(date +%Y%m%d-%H%M%S)"
put() {  # put <repo source> <destination>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
    cp "$dst" "$dst.bak-$STAMP"
    echo "  backup  $dst.bak-$STAMP"
  fi
  cp "$src" "$dst"
  echo "  ok      $dst"
}

echo "ghostty"
put ghostty/config        "$HOME/.config/ghostty/config"
put ghostty/make-blur.py  "$HOME/.config/ghostty/make-blur.py"

echo "herdr"
put herdr/config.toml     "$HOME/.config/herdr/config.toml"

echo "bin"
put bin/herdr-preflight   "$HOME/.local/bin/herdr-preflight"
chmod +x "$HOME/.local/bin/herdr-preflight"

echo "zsh"
put zsh/ghostty-herdr.zsh "$HOME/.config/zsh/ghostty-herdr.zsh"

echo "sounds"
if command -v ffmpeg >/dev/null; then
  bash herdr/sounds/make-sounds.sh "$HOME/.config/herdr/sounds"
else
  echo "  no ffmpeg: skipping the mp3s (brew install ffmpeg, then run herdr/sounds/make-sounds.sh)"
fi

cat <<'EOF'

Still manual (see README):
  1. Edit ~/.config/ghostty/config: set background-image to the ABSOLUTE path of your wallpaper.
     Build the blurred twin:  python3 ~/.config/ghostty/make-blur.py /path/to/wallpaper.jpg
  2. Add to ~/.zshrc, after PATH is set:   source ~/.config/zsh/ghostty-herdr.zsh
  3. Give Ghostty Accessibility permission (System Settings > Privacy & Security > Accessibility).
  4. Reload Ghostty (cmd+shift+,). If the herdr server is already running:  herdr server reload-config
EOF
