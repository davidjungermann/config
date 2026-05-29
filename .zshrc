# -----------------------------
# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
[[ -z "$ZSH_PROFILE" ]] || zmodload zsh/zprof
# -----------------------------

export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# Load plugins DIRECTLY from Homebrew
if [[ -f "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -f "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# History (OMZ defaults, kept after dropping oh-my-zsh)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY HIST_REDUCE_BLANKS

# Completions: skip the slow security audit if any dump is < 24h old
# (compinit writes per-host/version dumps like .zcompdump-HOST-VERSION)
autoload -Uz compinit
if [[ -n $HOME/.zcompdump*(#qN.mh-24) ]]; then
    compinit -C
else
    compinit
fi

# Powerlevel10k (Homebrew install — no oh-my-zsh required)
if [[ -f "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -----------------------------
# Environment Setup
# -----------------------------

# Pyenv (lazy-loaded; shims on PATH so python/pip resolve immediately.
# Caveat: pyenv-virtualenv's chpwd auto-activate hook isn't installed
# until the first `pyenv` invocation.)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    eval "$(command pyenv virtualenv-init -)"
    pyenv "$@"
}

# NVM (lazy-loaded; each wrapper is self-contained so shell snapshots
# that drop underscore-prefixed helpers still work)
export NVM_DIR="$HOME/.nvm"
if [[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
    nvm()  { unset -f nvm node npm npx; source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"; nvm  "$@"; }
    node() { unset -f nvm node npm npx; source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"; node "$@"; }
    npm()  { unset -f nvm node npm npx; source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"; npm  "$@"; }
    npx()  { unset -f nvm node npm npx; source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"; npx  "$@"; }
fi

export NODE_OPTIONS="--max-old-space-size=8192"


# Java
if [[ -d "$HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home" ]]; then
    export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
fi

# Jenv (lazy-loaded; shims on PATH so java/javac resolve immediately.
# Caveat: JAVA_HOME isn't auto-managed until the first `jenv` invocation.)
export PATH="$HOME/.jenv/bin:$HOME/.jenv/shims:$PATH"
jenv() {
    unset -f jenv
    eval "$(command jenv init -)"
    jenv "$@"
}

# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Cloud SQL Auth Proxy path
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# -----------------------------
# Aliases
# -----------------------------
alias brew='env PATH="${PATH//$PYENV_ROOT\/shims:/}" brew'
alias toggle="osascript -e 'tell app \"System Events\" to tell appearance preferences to set dark mode to not dark mode'"
alias awslogin='python /Users/djungermann/repos/personal/config/aws-cli/awslogin.py'
alias k='kubectl'
alias curlpod="kubectl run curlpod --rm -it --image=curlimages/curl -- sh"
alias cloud-sql-proxy="~/cloud-sql-proxy"

# Git aliases
alias gp='git push'
alias gpp='git push && gh pr create --web'

# -----------------------------
# Git Functions
# -----------------------------

# gbc - Git Branch Commit
# Automatically stages, creates a new branch, and commits with a formatted message
# Usage: gbc <branch-name> <commit-message>
# Example: gbc feature/SWIM-1337 "handles branches"
#          Creates branch: feature/SWIM-1337
#          Commit message: SWIM-1337: handles branches
gbc() {
  if [ $# -lt 2 ]; then
    echo "Usage: gbc <branch-name> <commit-message>"
    echo "Example: gbc feature/SWIM-1337 \"handles branches\""
    return 1
  fi

  local branch_name="$1"
  local commit_message="$2"

  git add .
  git checkout -b "$branch_name"

  # Extract ticket number from branch name if it exists (e.g., SWIM-1337 from feature/SWIM-1337)
  local ticket=$(echo "$branch_name" | grep -oE '[A-Z]+-[0-9]+')

  if [ -n "$ticket" ]; then
    # If ticket found, format as "TICKET: message"
    git commit -m "$ticket: $commit_message"
  else
    # Otherwise just use the commit message as-is
    git commit -m "$commit_message"
  fi
}


# -----------------------------
# Application Settings
# -----------------------------
export K9S_EDITOR=nvim
export EDITOR=nvim

# bun completions
[ -s "/Users/david/.bun/_bun" ] && source "/Users/david/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[[ -z "$ZSH_PROFILE" ]] || zprof
