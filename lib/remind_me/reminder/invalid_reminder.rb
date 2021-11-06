# frozen_string_literal: true

module RemindMe
  module Reminder
    class InvalidReminder
      attr_reader :source_location, :message

      def initialize(source_location, message)
        @source_location = source_location
        @message = message
      end
    end
  end
end
