#!/usr/bin/env bash
# Copia la configuracion a su sitio. Nunca pisa nada sin dejar un .bak con fecha.
# Uso:  ./install.sh          (desde la raiz del repo)
set -euo pipefail
cd "$(dirname "$0")"

STAMP="$(date +%Y%m%d-%H%M%S)"
put() {  # put <origen en el repo> <destino>
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
put herdr/preflight-clis  "$HOME/.config/herdr/preflight-clis"

echo "bin"
put bin/herdr-preflight   "$HOME/.local/bin/herdr-preflight"
chmod +x "$HOME/.local/bin/herdr-preflight"

echo "zsh"
put zsh/ghostty-herdr.zsh "$HOME/.config/zsh/ghostty-herdr.zsh"

echo "sounds"
if command -v ffmpeg >/dev/null; then
  bash herdr/sounds/make-sounds.sh "$HOME/.config/herdr/sounds"
else
  echo "  sin ffmpeg: salto los mp3 (brew install ffmpeg y corre herdr/sounds/make-sounds.sh)"
fi

cat <<'EOF'

Falta hacer a mano (ver README):
  1. Edita ~/.config/ghostty/config y pon la ruta ABSOLUTA de tu wallpaper.
     Genera la version difuminada:  python3 ~/.config/ghostty/make-blur.py /ruta/wallpaper.jpg
  2. Agrega a tu ~/.zshrc:   source ~/.config/zsh/ghostty-herdr.zsh
  3. Si el servidor de herdr ya corre:   herdr server reload-config
  4. Recarga Ghostty:  cmd+shift+,
EOF
