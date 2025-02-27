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

eval "$(starship init zsh)"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Java
export JAVA_HOME="$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

# bun completions
[ -s "/Users/djungermann/.bun/_bun" ] && source "/Users/djungermann/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

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

# Jenv (at the very end)
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Curlpod
alias curlpod="kubectl run curlpod --rm -it --image=curlimages/curl -- sh"
