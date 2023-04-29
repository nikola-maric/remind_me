# frozen_string_literal: true
require 'simplecov'

# Setting up simplecov to work properly with JRuby is a hassle, so we can ignore it - other builds will still use it though
if RSpec.configuration.files_to_run.size > 1 && RUBY_ENGINE != 'jruby'
  SimpleCov.minimum_coverage_by_file 80
  SimpleCov.minimum_coverage 90
  SimpleCov.start
end

require 'remind_me'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
