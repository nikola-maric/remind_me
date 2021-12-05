# frozen_string_literal: true

require_relative 'base_reminder'
require_relative '../utils/versions'

module RemindMe
  module Reminder
    class MissingGemReminder < BaseReminder
      include RemindMe::Utils::Versions

      apply_to_hash_with %i[missing_gem]
      validate_hash_ast key: :message, value_types: %i[str], default_value: 'Condition met!'

      def conditions_met?
        !gem_installed?(hash_missing_gem)
      end

    end
  end
end
