# frozen_string_literal: true

require_relative 'base_reminder'
require_relative '../utils/versions'

module RemindMe
  module Reminder
    class MissingGemReminder < BaseReminder
      apply_to_hash_with %i[missing_gem]

      validate_hash_ast key: :message, value_types: %i[str], default_value: 'Condition met!'

      include RemindMe::Utils::Versions

      def conditions_met?
        !gem_installed?(hash_missing_gem)
      end

      private

      def hash_missing_gem
        self.class.hash_ast_missing_gem_value(reminder_comment_ast).to_s # symbols are allowed, but we convert them
      end
    end
  end
end
