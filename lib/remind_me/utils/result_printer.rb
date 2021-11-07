# frozen_string_literal: true

module RemindMe
  module Utils
    class ResultPrinter
      include Utils::Logger

      attr_reader :reminders

      def initialize(reminders)
        @reminders = reminders
      end

      def print_results
        if reminders.empty?
          log_info 'No reminders found'
        else
          valid_reminders = reminders.reject { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
          invalid_reminders = reminders.select { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
          if invalid_reminders.size.positive?
            message = invalid_reminders.map(&:message).join("\n")
            log_error(message)
            abort
          else
            valid_condition_met_reminders = valid_reminders.select(&:conditions_met?)
            if valid_condition_met_reminders.size.positive?
              message = valid_condition_met_reminders.map(&:message).join("\n")
              log_error(message)
              abort
            else
              log_info "Found #{reminders.size} REMIND_ME comment(s), but none of the conditions were met..yet!"
            end
          end
        end
      end
    end
  end
end