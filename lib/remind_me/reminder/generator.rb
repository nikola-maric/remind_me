# frozen_string_literal: true

require_relative 'invalid_reminder'

module RemindMe
  module Reminder
    class Generator

      def self.register(reminder_klass)
        @registered_reminders ||= Set.new
        @registered_reminders << reminder_klass
      end

      def self.registered_reminders
        @registered_reminders.dup
      end

      def self.load_predefined_reminders
        predefined_remiders = Dir.entries(File.dirname(__FILE__)).select do |path|
          !path.end_with?('base_reminder.rb') && path.end_with?('_reminder.rb')
        end
        predefined_remiders.each { |f| require_relative f }
      end

      load_predefined_reminders

      def self.generate(source_location, reminder_comment, parser)
        parser.reset
        begin
          reminder_comment_ast = parser.class.parse(reminder_comment)
        rescue Parser::SyntaxError => e
          return [unparsable_reminder(source_location, e)]
        end
        relevant_reminders_classes = relevant_reminders_classes(reminder_comment_ast)
        return [unknown_reminder(source_location, reminder_comment)] if relevant_reminders_classes.empty?

        create_reminders_from(reminder_comment_ast, source_location, relevant_reminders_classes)
      end

      def self.relevant_reminders_classes(reminder_comment_ast)
        registered_reminders.select do |reminder_class|
          reminder_class.applicable_to_ast?(reminder_comment_ast)
        end
      end

      def self.create_reminders_from(reminder_comment_ast, source_location, relevant_reminders_classes)
        relevant_reminders_classes.map do |reminder_class|
          reminder_class.build_from(reminder_comment_ast, source_location)
        end
      end

      def self.unknown_reminder(source_location, reminder_comment)
        RemindMe::Reminder::InvalidReminder
          .new(source_location,
               "REMIND_ME comment in #{source_location}: found '#{reminder_comment}' but it was "\
                 'not applicable to any known reminder processors')
      end

      def self.unparsable_reminder(source_location, error)
        RemindMe::Reminder::InvalidReminder
          .new(source_location,
               "REMIND_ME comment in #{source_location}: unable to parse, message: #{error.message}")
      end

      private_class_method :unknown_reminder,
                           :unparsable_reminder,
                           :relevant_reminders_classes,
                           :create_reminders_from
    end
  end
end

