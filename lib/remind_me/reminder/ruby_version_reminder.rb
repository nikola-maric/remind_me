# frozen_string_literal: true

require_relative 'base_reminder'
require_relative '../utils/versions'

module RemindMe
  module Reminder
    class RubyVersionReminder < BaseReminder
      include RemindMe::Utils::Versions

      apply_to_hash_with %i[ruby_version]

      validate_hash_ast key: :message, value_types: %i[str], default_value: 'Condition met!'
      validate_hash_ast key: :condition, value_types: %i[sym str], default_value: :eq

      def conditions_met?
        condition = hash_condition
        target_ruby_version = Gem::Version.new(hash_ruby_version)
        installed_ruby_version = Gem::Version.new(RUBY_VERSION)
        compare_version_numbers(target_ruby_version, installed_ruby_version, condition)
      end

      def validation_errors
        errors = super
        errors << invalid_ruby_version_message if hash_ruby_version.nil? || hash_ruby_version == ''
        errors << malformed_version_string_message unless valid_version_string?(hash_ruby_version)
        errors << invalid_condition_message(source_location, hash_condition) unless valid_condition?(hash_condition)
        errors
      end

      private

      def invalid_ruby_version_message
        "REMIND_ME comment on #{source_location} has blank ruby version, you must specify version string"
      end

      def malformed_version_string_message
        "REMIND_ME comment in #{source_location} mentions '#{hash_ruby_version}' ruby version, but "\
        ' that is not a proper version string'
      end
    end
  end
end
