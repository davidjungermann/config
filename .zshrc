# -----------------------------
# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# -----------------------------

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Load plugins DIRECTLY from Homebrew (this works)
if [[ -f /opt/homebrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /opt/homebrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /opt/homebrew/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /opt/homebrew/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
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
export NVM_DIR=~/.nvm
if command -v brew >/dev/null 2>&1 && brew --prefix nvm >/dev/null 2>&1; then
    source $(brew --prefix nvm)/nvm.sh
fi

export NODE_OPTIONS="--max-old-space-size=8192"


# Java
if [[ -d "$(brew --prefix 2>/dev/null)/opt/openjdk/libexec/openjdk.jdk/Contents/Home" ]]; then
    export JAVA_HOME="$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
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

# Directory in iTerm title
if [ $ITERM_SESSION_ID ]; then
  precmd() {
    echo -ne "\033]0;${PWD##*/}\007"
  }
fi
