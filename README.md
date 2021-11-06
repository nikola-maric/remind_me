# RemindMe
[![Tests](https://github.com/nikola-maric/remind_me/workflows/Tests/badge.svg?branch=master)](https://github.com/nikola-maric/remind_me/actions?query=workflow%3ATests+branch%3Amaster)

This gem's main purpose is to scan a file or directory for specific comments in the code. Comments are
specified as a hash with `REMIND_ME:` (with a dot) prefixed to it, for example: 
`# REMIND_ME: { gem: 'rails', version: '5.2', condition: :gte, message: 'Remove this method once we switch to Rails 5.2'}`.

Idea is that we often get into situations like this: we create some functionality, but know some
limitations or that we should revisit this part of the code once conditions change, like:
- _"We should use `Comparable#clamp` once we upgrade to Ruby 2.4"_ 
- _"This patch won't be needed once we stop using `activerecord-multitenant` gem"_
- _"Remove this patch if #203 is merged into main after we bump version of `ruby-debug-ide`"_
- etc.

`TODO`-s are ok,
but if we are working with large codebase with lots of `TODO`-s sprinkled all over the place
we will probably never remember to revisit those parts of the code, and that TODO will stay there for
a looong time.

One of the options is to use something like [todo_or_die](https://github.com/searls/todo_or_die) which will work for these
use cases, but in my opinion is too invasive: you need to add code to your own code. Approach here is that you can define
a script or a rake task that will do this check for you, when you want it, for example in a CI environment. 
Other than that, these are just comments and won't affect your running code in any way.

If conditions are met for at least one reminder, script will print all of them out and abort 
(stopping your CI pipeline, for example). You should then revisit those parts of the code and either do some housekeeping
on the code, or remove/change reminder.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'remind_me'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install remind_me

## Usage

Script supports both single and multiline comments, so any of these will work:
```ruby
# REMIND_ME: { gem: 'rails', version: '6', condition: :gte, message: 'Check this once rails 6 is available'}
def monkey_patch_x
  1 + 1
end
```
```ruby
=begin
  some other comments
  REMIND_ME: { gem: 'rails', version: '6', condition: :gte, message: 'Check this once rails 6 is available'}
  more comments here
=end
def monkey_patch_x
  1 + 1
end
```
```ruby

def monkey_patch_x
  1 + 1 # REMIND_ME: { ruby_version: '2.4', condition: :gte, message: 'Check this once Ruby is >= 2.4'}
end
```

**Important note**: in order to find and parse those comments properly, there are some limitations on how comments are used:
- Entire `REMIND_ME: {}` comment needs to be on a single line, don't break it into multiple lines.
- Thing after `REMIND_ME:` needs to have ruby hash structure
- Both keys and values should be strings, symbols or strings/symbols, depending on reminder (for example, keys can
be given as symbols, but for `version` values strings are only allowed)

Each reminder type has a specific key that it "targets", for example `ruby_version`. If comment is found that does not 
match any reminder, we will print out error message specifying that + location where that reminder is found.

Same will happen if reminder is not a hash, or does not have required structure (
`REMIND_ME: { gem => ->() {exit(1)}.call }`), is unparsable (`REMIND_ME: {{ bla }`) or does not apply
to any known reminder processor.

### Supported reminder types

**GemVersionReminder**

Has following structure: 
`REMIND_ME: { gem: 'rails', version: '6', condition: :gte, message: 'Check this once rails 6 is available'}`.  
It targets all comment hash-es that have `gem/'gem'` in them as a key. 
It will look at currently installed gems and compare that version to target version specified in comment.

If version is omitted, we will only check if gem is installed or not (can be used to trigger
reminder when we add new gem). 

If condition is omitted, it will default to `eq`.  

if message is omitted, it will default to `'Condition met!'`

**MissingGemReminder**

Has following structure:
`REMIND_ME: { missing_gem: 'thor', message: 'Check this once we remove 'thor' gem'}`.  
It targets all comment hash-es that have `missing_gem/'missing_gem'` in them as a key.
It will look at currently installed gems and check to see if gem is installed, and will be triggered
if its not.

if message is omitted, it will default to `'Condition met!'`

**RubyVersionReminder**

Has following structure:
`REMIND_ME: { ruby_version: '3', condition: :gte, message: 'Check this once we start using Ruby 3.0+'}`.  
It targets all comment hash-es that have `ruby_version/'ruby_version'` in them as a key.
It will look at currently used ruby version and compare that version to target version specified in comment.

If condition is omitted, it will default to `eq`.

if message is omitted, it will default to `'Condition met!'`

### Usage example

No rake tasks is made available out-of-the-box: reason is that usually you want your app environment
to be loaded when running rake tasks (otherwise list of installed gems might be quite different). At least I didn't dig 
through enough to figure out how to instantiate proper environments from within gem code itself.
If you want to use it with Rails + rake, you can add something like this to your `.rake` file of choice:
```ruby
require 'remind_me/remind_me'

desc 'picks up REMIND_ME comments from codebase and checks if their conditions are met'
task kme: :environment do
  RemindMe::Runner.new.check_reminders # will default to using '.' if no explicit path is given
end
```
you could also pass arguments to your rake task and then invoke `Runner` with path specified that way, 
using `RemindMe::Runner.new.check_reminders(check_path: path_variable)`.

If `Rails` is defined, `Rails.logger` will be used for printing results, otherwise `puts` will be used. Make sure your Rails logger
is configured to work properly from within rake task.

## Future work

Expanding list of available reminders with other useful ones, for example:
- time based (we want to check something after specified date?)
- git_tag based ones (maybe we want to revisit something after version X is released?)
- file gets modified/deleted (when hash changes or file is missing)
- OS version changes...

Making use of Async ruby, al least for versions that have minimum ruby requirement > 3.0
(after we fetch all ruby files, creating and looking for reminders should be easily parallelizable)



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nikola-maric/remind_me. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/remind_me/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RemindMe project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/remind_me/blob/master/CODE_OF_CONDUCT.md).
