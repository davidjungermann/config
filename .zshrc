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

# Aliases
alias toggle="osascript -e 'tell app \"System Events\" to tell appearance preferences to set dark mode to not dark mode'"

eval "$(starship init zsh)"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Java
export JAVA_HOME="$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

# bun completions
[ -s "/Users/djungermann/.bun/_bun" ] && source "/Users/djungermann/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# AWS CLI script
sudo ln -s /Users/djungermann/repos/personal/aws-cli/awslogin.py /usr/local/bin
