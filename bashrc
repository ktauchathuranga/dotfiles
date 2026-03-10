# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

clone() {
    local BASEDIR="$HOME/cloned"
    mkdir -p "$BASEDIR" || return 1
    cd "$BASEDIR" || return 1

    if [ $# -eq 0 ]; then
        echo "Usage: clone <git-url>"
        return 1
    fi

    git clone "$@" || return 1

    # Get repo directory name (handles .git and paths)
    local repo
    repo="$(basename "${1%.git}")"

    cd "$repo" || return 0
}

# Quick Git Add All + Commit
gac() {
    local msg
    if [ $# -eq 0 ]; then
        msg="wip: $(date +'%Y-%m-%d %H:%M:%S')"
    else
        msg="$*"
    fi
    git add . && git commit -m "$msg"
}

# Quick Git Add All + Commit + Push
gacp() {
    local msg
    if [ $# -eq 0 ]; then
        msg="wip: $(date +'%Y-%m-%d %H:%M:%S')"
    else
        msg="$*"
    fi
    git add . && git commit -m "$msg" && git push
}

# Undo the last commit (but keep all file changes staged)
alias gundo="git reset --soft HEAD~1"

. "$HOME/.cargo/env"

# --- GIT PROMPT ADDITION ---
# Extract the current git branch
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ git:(\1)/'
}

# Set the prompt to include the branch

#  ktauchathuranga@certified-potato ~/cloned/dotfiles git:(main) $  
# export PS1="\[\e[32m\]\u@\h \[\e[34m\]\w\[\e[33m\]\$(parse_git_branch)\[\e[00m\] $ "

# ~/cloned/dotfiles git:(main) $
# export PS1="\[\e[34m\]\w\[\e[33m\]\$(parse_git_branch)\[\e[00m\] $ "

# ktauchathuranga ~/cloned/dotfiles git:(main) $
# export PS1="\[\e[32m\]\u \[\e[34m\]\w\[\e[33m\]\$(parse_git_branch)\[\e[00m\] $ "

# dotfiles git:(main) $ 
export PS1="\[\e[34m\]\W\[\e[33m\]\$(parse_git_branch)\[\e[00m\] $ "
