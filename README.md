# ghostty-herdr

Reference files for [Which One Needs Me](https://tyler07.me/notion/3da0c6d6bfa0810f91f2e40195eb329e) ([en español](https://tyler07.me/es/notion/3da0c6d6bfa0810f91f2e40195eb329e)). The post explains the setup; this repo is the exact config, the install order, and the traps.

Tested on macOS with Ghostty 1.3.1 and herdr 0.9.0.

```
ghostty/config              Vesper theme, left Option as Alt, the 23 herdr keybinds
ghostty/make-blur.py        makes the blurred twin of your wallpaper
herdr/config.toml           theme, toast, sound cues, the five prefix keys herdr ships unbound
herdr/preflight-clis        optional pinned list of agent CLIs to keep updated
herdr/sounds/make-sounds.sh builds the two mp3 cues from macOS system sounds
bin/herdr-preflight         updates agent CLIs once per new window, 12 h throttle, 90 s cap
zsh/ghostty-herdr.zsh       the two .zshrc pieces: preflight call + wallpaper blur hooks
install.sh                  copies everything into place, backs up what it replaces
```

## Install

Everything installs at once. The Alt keys only send herdr's `ctrl+b` prefix, so the prefix keeps working and you can still follow the post's advice of a week on `ctrl+b` before leaning on the shortcuts.

1. **Tools.**
   ```sh
   brew install --cask ghostty font-jetbrains-mono-nerd-font
   brew install ffmpeg                       # sound cues
   python3 -m pip install pillow             # make-blur.py (add --break-system-packages if pip refuses)
   curl -fsSL https://herdr.dev/install.sh | sh
   ```
   herdr installs to `~/.local/bin`. Make sure that directory is on your `PATH` before the next step, `herdr-preflight` lives there too.

2. **Files.** Existing files get a dated `.bak` next to them, nothing is deleted.
   ```sh
   git clone https://github.com/Vader-7/ghostty-herdr.git
   cd ghostty-herdr && ./install.sh
   ```

3. **Wallpaper.** In `~/.config/ghostty/config` set `background-image` to the **absolute** path of your image, then build the blurred twin next to it:
   ```sh
   python3 ~/.config/ghostty/make-blur.py /Users/you/Pictures/wallpaper.jpg   # writes wallpaper-blur.jpg
   ```
   Absolute path, same folder, `-blur` suffix: the zsh hook swaps the two by name and checks the file exists before touching anything. `~` is not expanded there.

4. **Shell.** Add this to `~/.zshrc`, after your `PATH` is set:
   ```sh
   source ~/.config/zsh/ghostty-herdr.zsh
   ```

5. **Accessibility.** System Settings → Privacy & Security → Accessibility → add Ghostty. The blur hook reloads Ghostty by sending `cmd+shift+,` through System Events. Without this permission macOS drops the keystroke and the wallpaper only changes on your next manual reload.

6. **Reload.** Open a new Ghostty window (or `cmd+shift+,`). If the herdr server was already running, `herdr server reload-config`.

7. **Agent CLIs.** On each new Ghostty window `herdr-preflight` updates every agent CLI herdr supports that is installed on your machine, at most once every 12 hours. `herdr-preflight --list` shows what it would touch, `--force` skips the throttle, `HERDR_PREFLIGHT_SKIP=1` turns it off. To pin the list instead of auto-detecting, copy `herdr/preflight-clis` to `~/.config/herdr/preflight-clis` and edit it.

Worktrees and orchestration are in the post, not here.

## The 23 shortcuts

All `left Option + key`. Ghostty sends herdr's prefix (`ctrl+b`, the byte `\x02`) followed by the herdr key, so herdr needs no rebinding except the five actions it ships unbound (`[keys]` in `herdr/config.toml`). If you change herdr's prefix, change `\x02` in every `keybind` line.

| Press | herdr gets | Does |
|---|---|---|
| alt+h / j / k / l | prefix+h/j/k/l | focus pane left / down / up / right |
| alt+z | prefix+z | zoom pane |
| alt+v | prefix+v | split vertical |
| alt+s | prefix+- | split horizontal |
| alt+` or alt+; | prefix+u | last pane (two keys, one action) |
| alt+g | prefix+g | goto: jump by name |
| alt+b | prefix+b | toggle sidebar |
| alt+tab / alt+shift+tab | prefix+a / prefix+A | previous / next workspace |
| alt+a / alt+shift+a | prefix+d / prefix+f | previous / next agent (skips shells) |
| alt+[ / alt+] | prefix+p / prefix+n | previous / next tab |
| alt+c | prefix+c | new tab |
| alt+shift+w | prefix+w | workspace selector |
| alt+shift+n | prefix+N | new workspace |
| alt+shift+r | prefix+W | rename workspace |
| alt+shift+t | prefix+T | rename tab |
| alt+shift+x | prefix+x | close pane |

23 bindings, not 24: the backtick and the semicolon are two keys for one action.

Native Ghostty splits stay on `cmd+d`, `cmd+shift+d` and `cmd+shift+enter`. They are not herdr panes.

## Traps

**`macos-option-as-alt = left`, not `true`.** On a US layout the default is already `true`, so the line does not win you the modifier. What it does is give the **right** Option back its dead keys, where accents and `ñ` live on ABC and Latin American layouts. Left Option drives the 23 bindings, right Option types `á`.

**`unfocused-split-opacity` never dims a herdr pane.** It only dims Ghostty's own splits. herdr draws all its panes inside one terminal surface, so Ghostty sees one split. Ghostty ships it at `0.7`; the `0.85` here only affects `cmd+d` splits.

**Toast is visual, sound is `[ui.sound]`.** `[ui.toast]` only controls the on-screen notice. Audio lives under `[ui.sound]` as `done_path` and `request_path`. The state the post calls *blocked* is `request` in herdr's config, so there is no `blocked_path`. With `delay_seconds = 5`, an agent that unblocks itself in under five seconds never notifies you.

**CLI updaters lie without a tty.** Several agent updaters exit `0` having done nothing when stdin is not a terminal. `herdr-preflight` runs each one under `script -q /dev/null` to hand it a pty, with stdin closed so an unexpected prompt aborts instead of hanging the shell. Output goes to `~/.local/state/herdr-preflight/update.log`.

**Keybinds are physical positions.** `key_h`, `bracket_left`, `backquote` are W3C key codes: they name the key, not the character. That matters for `;`, `[`, `]` and the backtick, which layouts do move. It does not matter for letters: US and Spanish are both QWERTY.

**The sounds are not in the repo.** They are macOS system sounds (`Purr` and `Tink`) lowered 8 dB, and Apple owns them. `install.sh` builds them with ffmpeg; without ffmpeg herdr just stays silent.

**The blur hook edits `~/.config/ghostty/config` in place.** Ghostty has no runtime API for this, so `_gh_bg` rewrites the `background-image` line with `sed`. Keep that line in the same shape and the substitution stays a one-liner. `_gh_preexec` blurs when the command is one of `_GH_WORK_CMDS`, `_gh_precmd` restores the sharp image only when no other pane still holds a live lock in `~/.cache/ghostty-work`.

## License

MIT.
