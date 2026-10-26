# shellcheck shell=bash
#
# musicplayer - a minimal music player for the macOS terminal.
# https://github.com/mahovo/musicplayer
#
# This file defines shell functions for bash and zsh, so it is sourced rather
# than run. Add this line to ~/.bash_profile (bash) or ~/.zshrc (zsh):
#
#     source ~/musicplayer/musicplayer.sh
#
# Then see 'man musicplayer' (or 'mpman') for the manual.
# Stop playback with ctrl+c.

# Settings. To change them, set them before the source line.
MUSICPLAYER_MUSIC_DIR=${MUSICPLAYER_MUSIC_DIR:-"$HOME/Music/iTunes/iTunes Music"}
MUSICPLAYER_PLAYLIST=${MUSICPLAYER_PLAYLIST:-"$HOME/.mpplaylist.txt"}

# Let 'man musicplayer' find the manual page in the man folder next to this file.
if [ -n "$ZSH_VERSION" ]; then
    # zsh: %x is this file, :A makes its path absolute, :h removes the file name
    # shellcheck disable=SC2296,SC2298
    _musicplayer_man=${${(%):-%x}:A:h}/man
else
    _musicplayer_man="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/man"
fi
case ":$MANPATH:" in
    *":$_musicplayer_man:"*) ;;  # already there
    *) export MANPATH="$_musicplayer_man:$MANPATH" ;;
esac
unset _musicplayer_man


# --- Browsing ---

# cd to the music dir and list its contents
music() {
    cd "$MUSICPLAYER_MUSIC_DIR" && ls | less
}

# Select artist folder and cd to that folder
artist() {
    cd "$MUSICPLAYER_MUSIC_DIR" || return 1

    local selected_dir
    # 'command ls' ignores any alias for ls, which could change what fzf reads
    selected_dir=$(command ls -d -- */ | fzf --preview 'ls {}' | tr -d '/')
    if [[ -d "$selected_dir" ]]; then
        cd -- "$selected_dir" || return 1
        printf '%s\n' "$selected_dir"
        ls
    else
        echo "Error: Selected path is not a directory." >&2
        return 1
    fi
}


# --- Playing ---

# Play the tracks listed on standard input, one path per line
mppipe() {
    local line
    printf "%s\n" "To stop, hit ctrl+c"
    while IFS= read -r line; do
        afplay -q 1 "$line"
    done
}

# Play all tracks in current dir
mpdir() {
    command ls -1 | grep -E '\.(mp3|m4a)$' | mppipe
}

# Play all tracks in all subdirectories, in random order
mpsub() {
    find . -type f \( -name "*.mp3" -o -name "*.m4a" \) | sort -R | mppipe
}

# Multi select tracks in current dir and play them.
# Select multiple files with tab (select and go to next) or shift-tab (select and go to previous).
mpplay() {
    command ls | fzf --multi | mppipe
}

# Select artist folder and play all tracks in all its subdirectories, in random order
mpartist() {
    artist && mpsub
}

# Find tracks by file name, select one and play it
mpfind() {
    cd "$MUSICPLAYER_MUSIC_DIR" || return 1
    find . -type f -name "*$1*" | fzf | mppipe
}


# --- Playlist ---

# Select tracks and append their full paths to the playlist
mpadd() {
    local file count=0
    touch "$MUSICPLAYER_PLAYLIST"  # zsh's NO_CLOBBER option stops >> from creating files
    while IFS= read -r file; do
        printf '%s\n' "$PWD/$file" >> "$MUSICPLAYER_PLAYLIST"
        count=$((count + 1))
    done < <(fzf --multi)
    printf "Added %d file(s) to the playlist.\n" "$count"
}

# Play playlist
mpplayl() {
    mppipe < "$MUSICPLAYER_PLAYLIST"
}

# Open playlist in your $EDITOR (vim if not set)
mpview() {
    # eval, so that EDITOR can include options, as in EDITOR="code -w"
    eval "${EDITOR:-vim}" '"$MUSICPLAYER_PLAYLIST"'
}

# Clear playlist
mpclear() {
    rm -f "$MUSICPLAYER_PLAYLIST"
    echo "Cleared the music player playlist."
}


# --- Help ---

# Music player manual
mpman() {
    man musicplayer
}
