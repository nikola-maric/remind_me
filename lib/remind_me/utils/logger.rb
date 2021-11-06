# frozen_string_literal: true

module RemindMe
  module Utils
    module Logger

      def log_info(msg)
        if defined?(Rails)
          Rails.logger.info green(msg)
        else
          puts green(msg)
        end
      end

      def log_error(msg)
        if defined?(Rails)
          Rails.logger.error red(msg)
        else
          puts red(msg)
        end
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
    end
  end
end