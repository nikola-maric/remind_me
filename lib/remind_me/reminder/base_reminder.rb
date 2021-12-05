# frozen_string_literal: true

require_relative '../utils/hash_ast_manipulations'
require_relative 'generator'

module RemindMe
  module Reminder
    class BaseReminder
      extend RemindMe::Utils::HashASTManipulations

      attr_reader :reminder_comment_ast, :source_location

      def self.inherited(base)
        RemindMe::Reminder::Generator.register(base)
        super(base)
      end

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
        "#{hash_message} at #{source_location}"
      end

      private

      def initialize(reminder_comment_ast, source_location)
        @reminder_comment_ast = reminder_comment_ast
        @source_location = source_location
      end
    end
  end
end
