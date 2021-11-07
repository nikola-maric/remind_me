# frozen_string_literal: true
require 'simplecov'

if RSpec.configuration.files_to_run.size > 1
  SimpleCov.minimum_coverage_by_file 80
  SimpleCov.minimum_coverage 90
  SimpleCov.start
end

require 'remind_me/remind_me'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
