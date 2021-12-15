require 'remind_me'

namespace :remind_me do
  desc 'picks up REMIND_ME comments from codebase and checks if their conditions are met'
  task check_reminders: :environment do
    RemindMe::Runner.check_reminders
  end
end
