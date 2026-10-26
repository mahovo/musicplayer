# musicplayer

A minimal music player for the macOS terminal, for bash and zsh.

musicplayer is a handful of shell functions for browsing your music folder and
playing it from the command line. You pick tracks with
[fzf](https://github.com/junegunn/fzf), and `afplay`, which comes with macOS,
plays them. There is no library to import: your music folder is the library,
and the playlist is a plain text file.

![Demo: mpartist opens a list of artist folders; typing "reih" narrows it to Rei Harakami, whose albums show in a preview; Enter starts shuffled playback and Ctrl-C stops it.](assets/demo.gif)

## Requirements

- macOS (for `afplay`)
- zsh, or bash 3.2 or later (both shells that come with macOS are fine)
- [fzf](https://github.com/junegunn/fzf): `brew install fzf`

## Installation

Clone the repository somewhere permanent:

```bash
git clone https://github.com/mahovo/musicplayer.git ~/musicplayer
```

Add this line to your `~/.zshrc` if you use zsh (the default shell on newer
Macs), or to your `~/.bash_profile` if you use bash:

```bash
source ~/musicplayer/musicplayer.sh
```

Then open a new terminal window and run `man musicplayer`.

musicplayer looks for your music in `~/Music/iTunes/iTunes Music`. If yours is
somewhere else, see [Configuration](#configuration).

## Usage

| Command | What it does |
| --- | --- |
| `music` | Go to the music folder and list what's in it |
| `artist` | Pick an artist folder and go to it |
| `mpdir` | Play all tracks in the current folder |
| `mpsub` | Play all tracks in the current folder and its subfolders, shuffled |
| `mpplay` | Pick tracks in the current folder and play them |
| `mpartist` | Pick an artist folder and play everything in it, shuffled |
| `mpfind [pattern]` | Pick a track whose file name contains *pattern* and play it |
| `mpadd` | Pick tracks and add them to the playlist |
| `mpplayl` | Play the playlist |
| `mpview` | Open the playlist in your editor |
| `mpclear` | Clear the playlist |
| `command \| mppipe` | Play the tracks that *command* lists, one path per line |
| `mpman` | Show the manual (same as `man musicplayer`) |

Press <kbd>Ctrl</kbd>+<kbd>C</kbd> to stop playback.
In the pickers, move with the arrow keys, select several tracks with
<kbd>Tab</kbd> and <kbd>Shift</kbd>+<kbd>Tab</kbd>, and press <kbd>Enter</kbd>
to confirm.

Because `mppipe` plays whatever you pipe into it, you can combine it with other
commands:

```bash
sort -R ~/.mpplaylist.txt | mppipe     # play the playlist in random order
tail -n 5 ~/.mpplaylist.txt | mppipe   # play the last five tracks you added

# like mpsub, but in alphabetical order instead of shuffled
find . -type f \( -name "*.mp3" -o -name "*.m4a" \) | sort | mppipe
```

## Configuration

Set these in `~/.zshrc` or `~/.bash_profile`, before the `source` line:

| Variable | Default | What it is |
| --- | --- | --- |
| `MUSICPLAYER_MUSIC_DIR` | `~/Music/iTunes/iTunes Music` | Your music folder |
| `MUSICPLAYER_PLAYLIST` | `~/.mpplaylist.txt` | The playlist file |
| `EDITOR` | `vim` | The editor `mpview` opens |

For example, the Music app usually keeps its files in
`~/Music/Music/Media.localized/Music`:

```bash
MUSICPLAYER_MUSIC_DIR="$HOME/Music/Music/Media.localized/Music"
source ~/musicplayer/musicplayer.sh
```

## Uninstalling

Remove the `source` line from `~/.zshrc` or `~/.bash_profile` and delete the
`musicplayer` folder. Your playlist stays in `~/.mpplaylist.txt`; delete it too if you like.

## License

[MIT](LICENSE)
