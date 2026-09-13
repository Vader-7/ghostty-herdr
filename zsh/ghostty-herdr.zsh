# ghostty-herdr · trozos de .zshrc
# Carga esto desde tu ~/.zshrc:   source ~/.config/zsh/ghostty-herdr.zsh
# Son exactamente dos cosas: (1) el preflight de CLIs, (2) el fondo difuminado.

# ─── herdr: CLIs al día antes de abrir herdr ──────────────
# Corre una sola vez por ventana nueva de Ghostty, nunca dentro de un panel de
# herdr (si no, se dispararia una vez por panel). Throttle de 12h en el script.
if [[ $- == *i* ]] && [[ $TERM_PROGRAM == ghostty ]] \
   && [[ -z ${HERDR_ENV:-} ]] && [[ -z ${CLAUDECODE:-} ]] && [[ -z ${CI:-} ]]; then
  herdr-preflight
fi

# ═══════ modo trabajo: difumina el fondo al abrir un agente ═══════
_GH_CFG="$HOME/.config/ghostty/config"
_GH_LOCKS="$HOME/.cache/ghostty-work"
_GH_WORK_CMDS=(claude opencode gemini codex crush aider nvim vim lazygit btop)

_gh_reload() {
  local fg
  fg=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
  [[ "$fg" == (ghostty|Ghostty) ]] || return 0
  osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}' >/dev/null 2>&1
}

_gh_bg() {                                  # _gh_bg blur | sharp
  [[ -f "$_GH_CFG" ]] || return 0
  local cur base ext new
  cur=$(sed -n 's/^background-image = //p' "$_GH_CFG")
  [[ -n "$cur" ]] || return 0
  ext="${cur##*.}"; base="${cur%.*}"; base="${base%-blur}"
  [[ "$1" == blur ]] && new="${base}-blur.${ext}" || new="${base}.${ext}"
  [[ "$cur" == "$new" ]] && return 0
  [[ -f "$new" ]] || return 0
  sed -i '' -E "s|^background-image = .*|background-image = ${new}|" "$_GH_CFG"
  _gh_reload
}

_gh_locks_alive() {                         # limpia PIDs muertos, devuelve cuantos quedan
  local f n=0
  mkdir -p "$_GH_LOCKS"
  for f in "$_GH_LOCKS"/*(N); do
    if kill -0 "${f:t}" 2>/dev/null; then (( n++ )); else rm -f "$f"; fi
  done
  return $(( n == 0 ))
}

autoload -Uz add-zsh-hook
_gh_preexec() {
  local -a _w; _w=(${(z)1}); local cmd=${_w[1]}
  (( ${_GH_WORK_CMDS[(Ie)$cmd]} )) || return 0
  mkdir -p "$_GH_LOCKS"; : > "$_GH_LOCKS/$$"
  _gh_bg blur
}
_gh_precmd() {
  rm -f "$_GH_LOCKS/$$" 2>/dev/null
  _gh_locks_alive || _gh_bg sharp          # solo si ningun otro panel sigue trabajando
}
add-zsh-hook preexec _gh_preexec
add-zsh-hook precmd  _gh_precmd
