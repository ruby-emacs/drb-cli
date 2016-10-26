#!/bin/bash
gem_file=`ls *drbcli* | grep -E "gem$"`
rm $gem_file
git add -A
gem build drbcli.gemspec
gem_file=`ls *drbcli* | grep -E "gem$"`
gem install $gem_file
cp ./bin/drb /usr/local/bin/drb
cp ./bin/drb-repl /usr/local/bin/drb-repl
