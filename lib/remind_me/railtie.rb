# frozen_string_literal: true

require 'remind_me'
require 'rails'

module RemindMe
  class Railtie < Rails::Railtie

    railtie_name :remind_me

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end

  end
end
