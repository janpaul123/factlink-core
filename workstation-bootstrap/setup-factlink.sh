#!/bin/bash
eval "$(rbenv init -)"

#abort this script on any error:
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$( cd "${DIR}"&& cd ../.. && pwd )"

if [ ! -d "$BASE_DIR/core/.git" ]; then
  echo "No core repo detected, installing all repo's in $BASE_DIR."
  read -p "Proceed? (y/N)" resp && echo $resp | egrep "^[yY]"
fi

#below are a few idempotent installer helper functions for git, brew and gem.
#npm install is already idempotent, it needs no helper function.
function cloneRepo {
  if [ ! -d "$1/.git" ]; then
    echo "cloning factlink $1 repo"
      git clone "git@github.com:Factlink/$1.git"
  else
    echo "$1 repo already present"
  fi
  pushd $1
  git checkout master
  #ignore failing to checkout develop - not all repos have that branch.
  git checkout develop || :
  popd
}

cd "$BASE_DIR"

cloneRepo server-management
cloneRepo core
cloneRepo chrome-extension
cloneRepo firefox-extension
cloneRepo js-library
cloneRepo web-proxy
cloneRepo chef-repo

RUBY_VERSION=`cat core/.ruby-version`

echo "Checking for ruby ${RUBY_VERSION}"

rbenv rehash || :
if bash -c "rbenv global ${RUBY_VERSION}" ; then
  #NOTE: we need to run the rbenv global TEST in a separate bash instance
  #because rbenv installs a bash function and due to set -e interaction in can fail.
  echo "Ruby ${RUBY_VERSION} already installed."
else
    echo "Installing ruby ${RUBY_VERSION}..."
    rbenv install ${RUBY_VERSION}
    rbenv rehash || :
fi

if ! type grunt 2>&1 >/dev/null; then
  #/usr/local/share/npm/bin isn't yet in path
  export PATH=$PATH:/usr/local/share/npm/bin
  if ! type grunt 2>&1 >/dev/null; then
    echo "ERROR: Cannot find grunt in path nor in /usr/local/share/npm/bin; exiting."
    exit 1
  fi
  echo 'export PATH=$PATH:/usr/local/share/npm/bin' >> ~/.bash_profile
fi

rbenv shell "${RUBY_VERSION}"


gem install bundler foreman git-up
rbenv rehash || :
rbenv shell --unset

echo 'Setting up web-proxy...'
cd web-proxy
  git flow init -d
  npm install
cd ..

echo 'Setting up chrome-extension...'
cd chrome-extension
  #TODO: npm install should be in package.json
  npm install yaml
  git flow init -d
  bin/release_repo 1
cd ..

echo 'Setting up firefox-extension...'
cd firefox-extension
  git flow init -d
cd ..

echo 'Setting up js-library...'
cd js-library
  git flow init -d
  npm install
  grunt
cd ..

echo 'Setting up chef-repo...'
cd chef-repo
# RSO broke the chef-repo bootstrap script, so this is currently disabled.
#  ./script/bootstrap
cd ..


echo 'Setting up core...'
cd core
  git flow init -d
  bundle install
  mkdir -p log
  cd log
    touch development.log
    touch production.log
    touch testserver.log
  cd ..

  foreman start -f ProcfileServers &
  FOREMAN_PID=$!
  bundle exec rake db:truncate
  bundle exec rake db:init
  kill ${FOREMAN_PID}
  wait

  # Bootstrap script should be run with current working directory in core
  #note that core's bootstrap script essentially just verifies that things that
  #setup_env.sh should do were done, so calling it from here only really
  #checkts that there's no mistakes in this script.
  bin/bootstrap
cd ..
echo
echo
brew outdated
echo "Your factlink development environment is done.  Happy hacking!"
