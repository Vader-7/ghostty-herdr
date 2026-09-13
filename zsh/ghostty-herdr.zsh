# ghostty-herdr · the two .zshrc pieces
# Source this from ~/.zshrc AFTER your PATH is set (it needs ~/.local/bin):
#   source ~/.config/zsh/ghostty-herdr.zsh
# Exactly two things: (1) the CLI preflight, (2) the wallpaper blur.

# ─── herdr: CLIs up to date before opening herdr ──────────
# Runs once per new Ghostty window, never inside a herdr pane (it would fire
# once per pane otherwise). The 12 h throttle lives in the script.
if [[ $- == *i* ]] && [[ $TERM_PROGRAM == ghostty ]] \
   && [[ -z ${HERDR_ENV:-} ]] && [[ -z ${CLAUDECODE:-} ]] && [[ -z ${CI:-} ]] \
   && (( $+commands[herdr-preflight] )); then
  herdr-preflight
fi

# ═══════ work mode: blur the wallpaper while an agent runs ═══════
# Needs macOS Accessibility permission for Ghostty (System Settings > Privacy &
# Security > Accessibility), otherwise the reload keystroke is silently dropped.
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

_gh_locks_alive() {                         # drops dead PIDs, returns 0 if any pane still works
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
  _gh_locks_alive || _gh_bg sharp          # only when no other pane is still working
}
add-zsh-hook preexec _gh_preexec
add-zsh-hook precmd  _gh_precmd
