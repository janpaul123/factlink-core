#!/bin/bash
echo "Running unit tests"
source "$HOME/.rvm/scripts/rvm"
rvm use --default 1.9.2-p290 || exit 1
export RUN_METRICS=TRUE
OUTPUTFILE=$(tempfile)
bundle exec rspec spec | tee "$OUTPUTFILE"
cat "$OUTPUTFILE" | grep ', 0 failures' || exit 1
exit