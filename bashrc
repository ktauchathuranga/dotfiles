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
    gac "$@" && git push
}

# Undo the last commit (but keep all file changes staged)
alias gundo="git reset --soft HEAD~1"

. "$HOME/.cargo/env"

# --- EXIT STATUS CAPTURE ---
PROMPT_COMMAND='LAST_EXIT=$?'

get_exit_status() {
    if [ $LAST_EXIT -eq 0 ]; then
        # Success: Green checkmark
        printf "\001\e[0;32m\002✓\001\e[0m\002"
    else
        # Failure: Red cross
        printf "\001\e[0;31m\002✗\001\e[0m\002"
    fi
}

# --- GIT PROMPT ADDITION ---
parse_git_branch() {
    # 1. Get branch name (Fastest way)
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    [ -z "$branch" ] && return # Exit if not in a git repo

    # 2. Check for changes (Very fast)
    # This checks for modified tracked files
    local status_symbol=""
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        status_symbol="*"
    # This checks for untracked files (Optional, remove if you only want tracked)
    elif [ -n "$(git ls-files --others --exclude-standard | head -n 1)" ]; then
        status_symbol="*"
    fi

    # 3. Print the prompt
    printf " \001\e[0;34m\002git:(\001\e[1;33m\002%s%s\001\e[0;34m\002)" "$branch" "$status_symbol"
}

# --- FINAL PROMPT MODES ---

# ktauchathuranga@certified-potato ~/cloned/dotfiles git:(main) ✓ $  
# export PS1="\[\e[1;36m\]\u@\h \[\e[1;32m\]\w\$(parse_git_branch) \$(get_exit_status) \[\e[0m\]$ "

# ~/cloned/dotfiles git:(main) ✓ $
# export PS1="\[\e[1;32m\]\w\$(parse_git_branch) \$(get_exit_status) \[\e[0m\]$ "

# ktauchathuranga ~/cloned/dotfiles git:(main) ✓ $
# export PS1="\[\e[1;36m\]\u \[\e[1;32m\]\w\$(parse_git_branch) \$(get_exit_status) \[\e[0m\]$ "

# dotfiles git:(main) ✓ $ 
export PS1="\[\e[1;32m\]\W\$(parse_git_branch) \$(get_exit_status) \[\e[0m\]$ "
