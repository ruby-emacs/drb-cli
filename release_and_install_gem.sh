gem build drbcli.gemspec
gem_file=`ls *drbcli* | grep -E "gem$"`
gem install $gem_file
