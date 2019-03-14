# Financo

Financo is a command line interface to download N26 bank transactions and create a ledger-cli compatible file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'financo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install financo

## Usage

``` bash
$ financo -h

# Download and convert N26 bank transactions into a Ledger journal
#
# Options:
#         --checking ACCOUNT_NAME      bank checking account (default 'Bank:Checking')
#     -o, --output OUTPUT              journal output: filename or STDOUT (default: journal-<timestamp>.ledger)
#     -v, --version                    show version
#     -h, --help                       show this message
#
# Usage:
#   financo [options] <username> <password>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/esnunes/financo.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
