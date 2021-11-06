# frozen_string_literal: true

module RemindMe
  module BailOut
    class Error < StandardError; end

    def bail_out!(message)
      raise RemindMe::BailOut::Error, message
    end
  end
end
