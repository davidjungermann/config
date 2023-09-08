# Pyenv
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Pyenv virtualenv
eval "$(pyenv virtualenv-init -)"

# GCloud SDK
source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"

# NVM
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# Aliases
alias proxy-test="~/cloud-sql-proxy wittra-backend-testing:europe-west1:wittra-pg-instance -p 5433"
alias proxy-dev="~/cloud-sql-proxy wittra-backend-dev:europe-west1:wittra-pg-instance -p 5433"
alias proxy-prod="~/cloud-sql-proxy wittra:europe-west1:wittra-pg-instance -p 5433"
alias proxy-next="~/cloud-sql-proxy cloud-next-9v6a:europe-west1:wittra-pg-instance -p 5433"

alias proxy-test-device-manager="~/cloud-sql-proxy wittra-backend-testing:europe-west1:device-manager-instance -p 5434"
alias proxy-dev-device-manager="~/cloud-sql-proxy wittra-backend-dev:europe-west1:device-manager-instance -p 5434"
alias proxy-prod-device-manager="~/cloud-sql-proxy wittra:europe-west1:device-manager-instance -p 5434"
alias proxy-next-device-manager="~/cloud-sql-proxy cloud-next-9v6a:europe-west1:device-manager-instance -p 5434"

alias proxy-test-billing="~/cloud-sql-proxy --auto-iam-authn wittra-backend-testing:europe-west1:billing-instance -p 5435"

eval "$(starship init zsh)"
