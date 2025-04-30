# Powerlevel10k + oh-my-zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Brew
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Pyenv virtualenv
eval "$(pyenv virtualenv-init -)"

# NVM
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# Java
export JAVA_HOME="$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

# Aliases
alias toggle="osascript -e 'tell app \"System Events\" to tell appearance preferences to set dark mode to not dark mode'"
alias awslogin='python /Users/djungermann/repos/personal/config/aws-cli/awslogin.py'
alias k='kubectl'
alias tp='telepresence'

# K9S
export K9S_EDITOR=nano
export EDITOR=nano

# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Directory in iterm title
if [ $ITERM_SESSION_ID ]; then
precmd() {
  echo -ne "\033]0;${PWD##*/}\007"
}
fi

# Cloud SQL Auth Proxy
alias cloud-sql-proxy="~/cloud-sql-proxy"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Curlpod
alias curlpod="kubectl run curlpod --rm -it --image=curlimages/curl -- sh"
