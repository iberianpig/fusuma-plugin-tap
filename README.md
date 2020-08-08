# Fusuma::Plugin::Tap [![Gem Version](https://badge.fury.io/rb/fusuma-plugin-tap.svg)](https://badge.fury.io/rb/fusuma-plugin-tap) [![Build Status](https://travis-ci.com/iberianpig/fusuma-plugin-tap.svg?branch=master)](https://travis-ci.com/iberianpig/fusuma-plugin-tap)

Tap gestures plugin for [Fusuma](https://github.com/iberianpig/fusuma)

* Add Tap gestures with 1, 2, 3, 4 fingers
* Add Hold gestures with 1, 2, 3, 4 fingers

## Installation

Run the following code in your terminal.

### Install fusuma-plugin-tap

```sh
$ sudo gem install fusuma-plugin-tap
```

### Add verbose and enable-tap

NOTE: **Fusuma require "Tap to click" and "verbose" option to libinput**

Open `~/.config/fusuma/config.yml` and add the following code at the bottom.
If you already have `libinput_command_input` section, just add `enable-tap` and `verbose: true`.

```yaml
plugin: 
  inputs:
    libinput_command_input:
      enable-tap: true
      verbose: true
```

### Add tap and hold parameter

Set `tap:` and `:hold` property and values under gesture in `~/.config/fusuma/config.yml`.

```yaml
tap:
  1:
    command: "echo ----------------tap1----------------------------"
  2:
    command: "echo ----------------tap2----------------------------"
  3:
    command: "echo ----------------tap3----------------------------"
  4:
    command: "echo ----------------tap4----------------------------"

hold:
  1:
    command: "echo ----------------hold1----------------------------"
  2:
    command: "echo ----------------hold2----------------------------"
  3:
    command: "echo ----------------hold3----------------------------"
  4:
    command: "echo ----------------hold4----------------------------"

plugin: 
  inputs:
    libinput_command_input:
      enable-tap: true
      verbose: true
```

## Known issues
* `libinput debug-events --verbose` outputs is unstable, so it may not work properly with some versions of libinput.
* **libinput 1.10.4 contains a bug that suddenly stopped detecting taps.**

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iberianpig/fusuma-plugin-tap. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fusuma::Plugin::Tap project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/iberianpig/fusuma-plugin-tap/blob/master/CODE_OF_CONDUCT.md).
