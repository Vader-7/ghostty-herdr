# ghostty-herdr

The terminal setup behind [Which One Needs Me](https://tyler07.me/notion/3da0c6d6bfa0810f91f2e40195eb329e) ([versión en español](https://tyler07.me/es/notion/3da0c6d6bfa0810f91f2e40195eb329e)): Ghostty as the window, herdr as the multiplexer, and a shell that answers one question when several coding agents are running at once: which one stopped and needs me.

The post explains the *why*. This repo is the reference: the exact files, in the order you install them, plus the traps that cost hours the first time.

Tested on macOS with Ghostty 1.3.1 and herdr 0.9.0. Comments inside the config files are in Spanish; everything you need to act on is in this README.

## What is in here

```
ghostty/config              Vesper theme, Alt-left as modifier, 23 herdr keybinds
ghostty/make-blur.py        makes the blurred copy of your wallpaper
herdr/config.toml           theme, toast, sound, and the five prefix keys herdr ships unbound
herdr/preflight-clis        which agent CLIs to keep updated (one per line)
herdr/sounds/make-sounds.sh builds the two mp3 cues from macOS system sounds
bin/herdr-preflight         updates agent CLIs once per new window, 12 h throttle, 90 s cap
zsh/ghostty-herdr.zsh       the two .zshrc pieces: preflight call + wallpaper blur hooks
install.sh                  copies everything into place, backs up what it replaces
```

## Install, in order

The order matters. Ghostty first, herdr second, keys last, and only after a week of using herdr's default `ctrl+b` prefix so the states (`working`, `request`, `done`, `idle`) mean something to you.

1. **Prerequisites.**
   ```sh
   brew install --cask ghostty
   brew install --cask font-jetbrains-mono-nerd-font
   brew install ffmpeg            # only for the sound cues
   pip3 install pillow            # only for make-blur.py
   ```
   Install herdr from [herdr.dev](https://herdr.dev). The script expects the binary at `~/.local/bin/herdr` (override with `HERDR_BIN_PATH`).

2. **Clone and install.** Existing files get a dated `.bak` next to them, nothing is deleted.
   ```sh
   git clone https://github.com/Vader-7/ghostty-herdr.git
   cd ghostty-herdr && ./install.sh
   ```

3. **Wallpaper.** Edit `~/.config/ghostty/config`, set `background-image` to the **absolute** path of your image, then build the blurred twin next to it:
   ```sh
   python3 ~/.config/ghostty/make-blur.py /Users/you/Pictures/wallpaper.jpg   # writes wallpaper-blur.jpg
   ```
   The path must be absolute and the `-blur` file must sit beside the original: the zsh hook swaps the two by name and does a file test before touching anything. `~` is not expanded there.

4. **Shell.** Add one line to `~/.zshrc`, then open a new Ghostty window:
   ```sh
   source ~/.config/zsh/ghostty-herdr.zsh
   ```

5. **Reload.** `cmd+shift+,` reloads Ghostty. If herdr's server is already running, `herdr server reload-config` picks up the new `config.toml`.

6. **Agent CLIs.** `herdr/preflight-clis` lists what `herdr-preflight` keeps updated. Delete or empty the file and it auto-detects instead: every agent kind herdr supports that is also on your `PATH`. Run `herdr-preflight --list` to see what it would touch, `--force` to skip the throttle.

That is the whole setup. Worktrees, orchestration and the briefing template are in the post, not here.

## The 23 shortcuts

All of them are `left Option + one key`. Ghostty translates each into herdr's prefix (`ctrl+b`, sent as `\x02`) followed by the herdr key, so herdr itself needs no rebinding except the five actions it ships unbound (see `[keys]` in `herdr/config.toml`). If you change herdr's prefix, change `\x02` in every `keybind` line.

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

Count: 7 + 2 + 2 + 2 + 2 + 3 + 5 = 23 bindings. Not 24, the backtick and the semicolon are two keys for the same action.

Start with ten: `hjkl`, the workspace pair, the agent pair, `v`, `s`, `z`. Add the rest when those are in your fingers.

Native Ghostty splits stay on `cmd+d` and `cmd+shift+d`, with `cmd+shift+enter` to zoom. They are a different thing from herdr panes.

## Traps

These are verified. Each one cost real time.

**`macos-option-as-alt = left`, not `true`.** On a US layout the default is already `true`, so the line does not *win* you the modifier. What it does is give the **right** Option back its dead keys, which is where accents and `ñ` live on ABC and Latin American layouts. Left Option drives the 23 bindings, right Option types `á`.

**`unfocused-split-opacity` never dims a herdr pane.** It only dims Ghostty's own native splits. herdr draws all its panes inside one terminal surface, so Ghostty sees one split. Ghostty also ships it at `0.7` already; the `0.85` in this config only matters for `cmd+d` splits.

**Toast is visual, sound is `[ui.sound]`.** `[ui.toast]` only controls the on-screen notice. Audio lives under `[ui.sound]` with `done_path` and `request_path`. herdr calls the needs-you state **`request`**, not `blocked`, and there is no `blocked_path`. `delay_seconds = 5` means an agent that unblocks itself in under five seconds never notifies you.

**CLI updaters lie without a tty.** Several agent updaters exit `0` having done nothing when stdin is not a terminal. `herdr-preflight` runs each one under `script -q /dev/null` to hand it a pty, with stdin closed so an unexpected prompt aborts instead of hanging your shell. Output goes to `~/.local/state/herdr-preflight/update.log`.

**Keybinds are physical positions.** `key_h`, `bracket_left`, `backquote` are W3C key codes: they name the physical key, not the character. That matters for `;`, `[`, `]` and the backtick, which layouts do move. It does not matter for the letters: US and Spanish are both QWERTY.

**The sounds are not in the repo.** They are macOS system sounds (`Purr` and `Tink`) lowered 8 dB, and Apple owns them. `make-sounds.sh` builds them on your machine in two seconds.

## How the blur hook works

`_gh_preexec` fires before every command. If the first word is one of `_GH_WORK_CMDS` (claude, codex, gemini, nvim, lazygit…) it drops a lock file named after the shell's PID, rewrites `background-image` to the `-blur` twin, and asks Ghostty to reload with `cmd+shift+,` via AppleScript, only if Ghostty is the frontmost app. `_gh_precmd` removes the lock when the command returns and restores the sharp image only when no other pane still holds a live lock. Dead PIDs are cleaned on the way.

It edits `~/.config/ghostty/config` in place with `sed`. That is by design: Ghostty has no runtime API for this. Keep the config under this repo's shape and the `sed` stays a one-line substitution.

## License

MIT.
