# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

begin
  require 'rb_sys/extensiontask'
  RbSys::ExtensionTask.new('remind_me_native') do |ext|
    ext.lib_dir = 'lib/remind_me'
  end
rescue LoadError
  # rb_sys not available, skip native extension compilation task
end

task default: %i[spec rubocop]
