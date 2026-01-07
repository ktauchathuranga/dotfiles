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

