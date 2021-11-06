# frozen_string_literal: true

require_relative '../bail_out'
require_relative 'invalid_reminder'
require_relative '../utils/hash_ast_manipulations'

module RemindMe
  module Reminder
    class BaseReminder
      extend RemindMe::Utils::HashASTManipulations

      attr_reader :reminder_comment_ast, :source_location

      def conditions_met?
        raise NotImplementedError
      end

      def validation_errors
        []
      end

      def inspect
        "#<#{self.class}, source: #{source_location}>"
      end

      def message
        "#{self.class.hash_ast_message_value(reminder_comment_ast)} at #{source_location}"
      end

      private

      def initialize(reminder_comment_ast, source_location)
        @reminder_comment_ast = reminder_comment_ast
        @source_location = source_location
      end
    end
  end
end
