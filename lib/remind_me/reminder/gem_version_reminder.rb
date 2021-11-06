# frozen_string_literal: true

require_relative 'base_reminder'
require_relative '../utils/versions'
require_relative '../utils/hash_ast_manipulations'

module RemindMe
  module Reminder
    class GemVersionReminder < BaseReminder
      include RemindMe::Utils::Versions

      apply_to_hash_with %i[gem]

      validate_hash_ast key: :gem, value_types: %i[str sym]
      validate_hash_ast key: :version, value_types: %i[str]
      validate_hash_ast key: :message, value_types: %i[str], default_value: 'Condition met!'
      validate_hash_ast key: :condition, value_types: %i[sym str], default_value: :eq

      def conditions_met?
        target_version = hash_version
        # if no version is specified, look for any version
        if target_version.nil? || target_version.empty?
          gem_installed?(hash_gem)
        else
          return false unless INSTALLED_GEMS[hash_gem]

          condition = hash_condition
          target_gem_version = Gem::Version.new(target_version)
          installed_gem_version = INSTALLED_GEMS[hash_gem]
          compare_version_numbers(target_gem_version, installed_gem_version, condition.to_sym)
        end
      end

      def validation_errors
        errors = super
        errors << gem_missing_message unless gem_installed?(hash_gem)
        errors << invalid_condition_message(source_location, hash_condition) unless valid_condition?(hash_condition)
        errors << malformed_version_string_message unless valid_version_string?(hash_version)
        errors
      end

      private

      def hash_gem
        self.class.hash_ast_gem_value(reminder_comment_ast).to_s
      end

      def hash_version
        self.class.hash_ast_version_value(reminder_comment_ast)
      end

      def hash_condition
        self.class.hash_ast_condition_value(reminder_comment_ast)
      end

      def gem_missing_message
        "REMIND_ME comment in #{source_location} mentions '#{hash_gem}' gem, but that gem is not installed"
      end

      def malformed_version_string_message
        "REMIND_ME comment in #{source_location} mentions '#{hash_gem}' gem, but version specified: '#{hash_version}'"\
        ' is not proper version string'
      end
    end
  end
end
