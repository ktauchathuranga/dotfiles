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

# Quick Git Add All + Commit + Push (with rebase fail-safe)
gacp() {
    local msg
    if [ $# -eq 0 ]; then
        msg="wip: $(date +'%Y-%m-%d %H:%M:%S')"
    else
        msg="$*"
    fi

    git add .
    git commit -m "$msg"

    echo -e "\n\033[1;34mPulling latest changes...\033[0m"
    if git pull --rebase; then
        echo -e "\033[1;32mRebase successful. Pushing code...\033[0m"
        git push
    else
        echo -e "\n\033[1;31mRebase conflict detected. Push aborted.\033[0m"
        echo -e "You are currently paused mid-rebase."
        echo -e "\nTo fix this:"
        echo -e "  1. Resolve the conflicts in your editor."
        echo -e "  2. Run: \033[1;33mgit add .\033[0m"
        echo -e "  3. Run: \033[1;33mgit rebase --continue\033[0m"
        echo -e "  4. Run: \033[1;33mgit push\033[0m\n"
        return 1
    fi
}

# Quick Git Pull (Rebase to keep history clean during pair programming)
gpl() {
    git pull --rebase "$@"
}

# Quick Git Sync (Pull with rebase, then Push)
gsync() {
    git pull --rebase && git push
}

# Clear the terminal quickly
alias cl="clear"

. "$HOME/.cargo/env"

# --- EXIT STATUS CAPTURE ---
PROMPT_COMMAND='LAST_EXIT=$?'

get_exit_status() {
    if [ $LAST_EXIT -eq 0 ]; then
        # Success: Green checkmark (Bold Green)
        printf "\001\e[1;32m\002✓\001\e[0m\002"
    else
        # Failure: Red cross (Bold Red)
        printf "\001\e[1;31m\002✗\001\e[0m\002"
    fi
}

# --- GIT PROMPT ADDITION ---
parse_git_branch() {
    # 1. Get branch name or commit hash (Fastest way, with Detached HEAD support)
    local branch=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    [ -z "$branch" ] && return # Exit if not in a git repo

    # 2. Check for changes (Very fast, with locks disabled for performance)
    # This checks for modified tracked files
    local status_symbol=""
    if ! git --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null; then
        status_symbol="*"
    # This checks for untracked files (Optional, remove if you only want tracked)
    elif [ -n "$(git --no-optional-locks ls-files --others --exclude-standard | head -n 1)" ]; then
        status_symbol="*"
    fi

    # 3. Print the prompt
    # Light Blue Text & Parentheses: \e[1;36m | Red Branch: \e[0;31m
    printf " \001\e[1;36m\002git:(\001\e[0;31m\002%s%s\001\e[1;36m\002)" "$branch" "$status_symbol"
}

# --- FINAL PROMPT MODES ---

# Global Prompt Symbol Configuration
# Include the trailing space here so removing the symbol removes the space too
# ❯
export PROMPT_SYMBOL=""

# ktauchathuranga@certified-potato ~/cloned/dotfiles git:(main) ✓ ❯ 
# export PS1="\[\e[1;32m\]\u@\h \[\e[0;34m\]\w\$(parse_git_branch) \$(get_exit_status) \[\e[0m\]${PROMPT_SYMBOL}"

# ~/cloned/dotfiles git:(main) ✓ ❯
 export PS1="\[\e[0;34m\]\w\$(parse_git_branch) \$(get_exit_status) \[\e[0m\]${PROMPT_SYMBOL}"

# ktauchathuranga ~/cloned/dotfiles git:(main) ✓ ❯
# export PS1="\[\e[1;32m\]\u \[\e[0;34m\]\w\$(parse_git_branch) \$(get_exit_status) \[\e[0m\]${PROMPT_SYMBOL}"

# dotfiles git:(main) ✓ ❯ 
# export PS1="\[\e[0;34m\]\W\$(parse_git_branch) \$(get_exit_status) \[\e[0m\]${PROMPT_SYMBOL}"