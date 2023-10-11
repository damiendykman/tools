
#################################################
# Load secrets

source ~/.bash_profile_secrets

#################################################
# Bash prompt colors & Git

# Git completion (see https://gist.github.com/henrik/31631 and
# https://github.com/git/git/blob/master/contrib/completion/git-completion.bash)

# Colors
export CLICOLOR=1
# White bg
#export LSCOLORS=ExFxCxDxBxegedabagacad
# Black bg
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# Prompt
export PS1='\[\e[1;32m\]\u@\h: \w${text}$\[\e[m\] '

# Git prompt
function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}
export PS1='\[\033[1;33m\]\w\[\033[0m\]$(parse_git_branch)$ '

# Download git-completion.bash if missing
if [[ ! -e ~/git-completion.bash ]]; then
  echo "******** To have git completion, download manually raw version https://github.com/git/git/blob/master/contrib/completion/git-completion.bash ********"
fi

# Source git-completion.bash
. ~/git-completion.bash

#################################################
# AWS profiles

function aws-refresh {
  aws sts get-caller-identity &>/dev/null
  if [[ $? != 0 ]]; then
    echo -e "Getting creds from AWS for profile ${PROFILE_NAME}"
    aws sso login
  else
    echo "Good to go!"
  fi
}

function aws-profile {
  echo AWS_PROFILE=$AWS_PROFILE
  aws sts get-caller-identity
}

function aws-profile-list {
  cat ~/.aws/config | grep "^\[profile "
}

function aws-profile-set {
  export AWS_PROFILE=$1
  echo AWS_PROFILE=$AWS_PROFILE
}

function aws-profile-unset {
  unset AWS_PROFILE
  echo AWS_PROFILE=$AWS_PROFILE
}

# Enable auto completion on aws commands
complete -C "$(which aws_completer)" aws

# # AWS stuff
# # Needed to be able to run: helm secrets enc secrets.yaml
# export AWS_SDK_LOAD_CONFIG=1


#################################################
# Some aliases

alias rm='rm -i'
alias ll='ls -l'
alias a='ls -a'
alias port='lsof -n -i4TCP:8081'
alias aws-s3-ls='aws s3 ls --human-readable --recursive --summarize'
alias aws-tail='aws logs tail --region=us-west-2 --follow'
alias mvnci='mvn clean install -DskipTests=true'
alias k='kubectl'
alias kc='kubectl config get-contexts'
alias saml='saml2aws login --session-duration=43200'
alias dc='docker-compose'
alias jyq='jq -c . | yq eval -P -'
alias yjq='yq eval -o=json'

#################################################
# Some random stuff

# Reload .bash_profile and secrets
function bash-reload-profile {
  source ~/.bash_profile
}


# Recommended by brew install npm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


#################################################
# Virtualenv

function venv-list {
  ls ~/tmp/venvs/
}

function venv-activate {
  if [ -z "$1" ]; then
    /bin/echo "Missing venv"
    return 1  
  fi
  source ~/tmp/venvs/$1/bin/activate
}

function venv-create {
  if [ -z "$1" ]; then
    /bin/echo "Missing venv"
    return 1  
  fi
  virtualenv ~/tmp/venvs/$1
  venv-activate $1

  #pip install black flake8
}

function venv-delete {
  if [ -z "$1" ]; then
    /bin/echo "Missing venv"
    return 1  
  fi
  read -p "Delete venv $1?" yesno
  rm -rf "~/tmp/venvs/$1" 
  echo "Done deleteing venv $1"
}

#################################################
# Python stuff

function python-clean {
  black *.py tests/*.py
  flake8 *.py tests/*.py
  isort *.py tests/*.py
}

function python-clean-recursive {
  find . -name '*.py' | xargs black
  find . -name '*.py' | xargs flake8
  find . -name '*.py' | xargs isort
}

function python-path-append {
    if [ -z "$1" ]; then
    /bin/echo "Missing path"
    return 1  
  fi
  if [ -z "$PYTHONPATH" ]; then
    export PYTHONPATH="$1"
  else
    export PYTHONPATH="$PYTHONPATH:$1"
  fi
  echo PYTHONPATH=$PYTHONPATH
}

function python-path-reset {
  unset PYTHONPATH
}

#################################################
# Docker

# Remove exited containers
function docker-rm () { 
    docker ps -a -f status=exited | grep -v "^CONTAINER" | cut -f1 -d ' ' | xargs docker rm
}

# Turn off bell
bind 'set bell-style none'

