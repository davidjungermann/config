# -----------------------------
# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
[[ -z "$ZSH_PROFILE" ]] || zmodload zsh/zprof
# -----------------------------

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# Load plugins DIRECTLY from Homebrew (this works)
if [[ -f "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -f "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting.zsh"
fi

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Only git plugin
plugins=(git)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -----------------------------
# Environment Setup
# -----------------------------

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# NVM
export NVM_DIR="$HOME/.nvm"
if [[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
    _load_nvm() {
        unset -f nvm node npm npx
        source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
    }
    nvm() { _load_nvm; nvm "$@"; }
    node() { _load_nvm; node "$@"; }
    npm() { _load_nvm; npm "$@"; }
    npx() { _load_nvm; npx "$@"; }
fi

export NODE_OPTIONS="--max-old-space-size=8192"


# Java
if [[ -d "$HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home" ]]; then
    export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
fi

# Jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Cloud SQL Auth Proxy path
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# -----------------------------
# Aliases
# -----------------------------
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
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
