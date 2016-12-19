# Drbcli

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/drbcli`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
ruby '~> 2.4.0'
gem 'drbcli', '~> 0.1.4', git: "https://github.com/ruby-emacs/drb-cli.git"
```

And then execute:

    $ bundle

## Usage

### workflow

1. Start a drb debug server in your code's anywhere. One way to start drb server
   is in console like (irb or pry console, or Rails console). It just added
   binding for console environment.

```ruby
drb_start binding
# Server running at druby://localhost:9000
```

2. Then run drb client command on Ruby source code file to execute:

```shell
/your-gem-path/drb-cli/bin/drb file.rb 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/drbcli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

