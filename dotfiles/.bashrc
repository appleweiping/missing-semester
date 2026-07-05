# ~/.bashrc — Missing Semester dotfiles
# Sourced by interactive non-login bash shells.

# --- History ---
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth        # no duplicate lines, no lines starting with space
shopt -s histappend           # append instead of overwrite
shopt -s checkwinsize         # keep LINES/COLUMNS current

# --- Prompt (command-line lecture exercise: customize $PS1) ---
# Show exit-status of last command, cwd, and git branch.
__git_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's/^/ (/;s/$/)/'
}
__prompt_status() {
    local code=$?
    [ "$code" -ne 0 ] && printf '\[\e[31m\][%d]\[\e[0m\] ' "$code"
}
PS1='$(__prompt_status)\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(__git_branch)\[\e[0m\]\$ '

# --- Aliases (command-line lecture exercise) ---
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias dc='cd'                 # typo-correction alias from the aliases exercise

# git shortcuts
alias gs='git status'
alias gl='git log --all --graph --decorate --oneline'
alias gd='git diff'

# --- Source aliases file if present ---
[ -f ~/.aliases ] && . ~/.aliases

# --- Enable programmable completion ---
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
