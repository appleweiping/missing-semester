#!/usr/bin/env bash
# install.sh — symlink the dotfiles into $HOME (command-line lecture, dotfiles ex 3).
# Idempotent: existing files are backed up to *.bak once, then symlinked.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Files to link from this directory into $HOME (as dot-prefixed names).
FILES=(.bashrc .aliases .vimrc .gitconfig .gitignore_global .tmux.conf)

link() {
    local src="$1" dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "backing up existing $dst -> $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"
    echo "linked $dst -> $src"
}

echo "Installing dotfiles from $DOTFILES_DIR"
for f in "${FILES[@]}"; do
    link "$DOTFILES_DIR/$f" "$HOME/$f"
done

# functions.sh lives un-dotted; link it too and make sure .bashrc sources it.
link "$DOTFILES_DIR/functions.sh" "$HOME/functions.sh"
if ! grep -q 'functions.sh' "$HOME/.bashrc" 2>/dev/null; then
    echo '[ -f ~/functions.sh ] && . ~/functions.sh' >> "$HOME/.bashrc"
fi

echo "Done. Open a new shell or run: source ~/.bashrc"
