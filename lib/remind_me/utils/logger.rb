# frozen_string_literal: true

module RemindMe
  module Utils
    module Logger

      def log_info(msg)
        rails_being_used? ? log_with_rails(green(msg), :info) : puts(green(msg))
      end

      def log_error(msg)
        rails_being_used? ? log_with_rails(red(msg), :error) : puts(red(msg))
      end

      def colorize(color_code, string)
        "\e[#{color_code}m#{string}\e[0m"
      end

      def red(string)
        colorize(31, string)
      end

      def green(string)
        colorize(32, string)
      end

      def rails_being_used?
        defined?(Rails)
      end

      def log_with_rails(msg, severity)
        Rails.logger.send(severity, msg)
      end
    end
  end
end