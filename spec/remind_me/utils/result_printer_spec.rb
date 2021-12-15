# frozen_string_literal: true
require 'spec_helper'
require 'remind_me/reminder/ruby_version_reminder'

RSpec.describe RemindMe::Utils::ResultPrinter do

  before(:each) do
    allow_any_instance_of(Object).to receive(:puts)
  end

  describe "#print_results" do
    it 'prints appropriate message when there are no reminders' do
      subject = described_class.new([])
      expect(subject).to receive(:log_info).with('No reminders found')
      subject.print_results
    end

    it 'prints invalid reminder messages when there are invalid reminders' do
      subject = described_class.new([
        create_invalid_reminder('Error parsing reminder 1', location('1')),
        create_invalid_reminder('Error parsing reminder 2', location('2')),
        create_condition_met_reminder('Condition met 3', location('3')),
        create_condition_not_met_reminder('Condition not met 4', location('4'))
      ])
      expect(subject).to receive(:log_error)
        .with("Error parsing reminder 1\nError parsing reminder 2")
      expect(subject).to receive(:abort).once
      subject.print_results
    end

    it 'prints condition met reminder messages when there are reminders whose conditions are met' do
      subject = described_class.new([
        create_condition_met_reminder('Condition met 1', location('1')),
        create_condition_met_reminder('Condition met 2', location('2')),
        create_condition_not_met_reminder('Condition met 3', location('3'))
      ])
      expect(subject).to receive(:log_error)
        .with("Condition met 1 at #{location('1')}\nCondition met 2 at #{location('2')}")
      expect(subject).to receive(:abort).once
      subject.print_results
    end

    it 'prints appropriate message when there are no reminders whose conditions are met' do
      subject = described_class.new([
        create_condition_not_met_reminder('Condition met 1', location('1')),
        create_condition_not_met_reminder('Condition met 2', location('2'))
      ])
      expect(subject).to receive(:log_info)
        .with("Found 2 REMIND_ME comment(s), but none of the conditions were met..yet!")
      subject.print_results
    end
  end

  def create_invalid_reminder(message, source_location)
    RemindMe::Reminder::InvalidReminder.new(source_location, message)
  end

  def create_condition_met_reminder(message, source_location)
    comment_string = "{ ruby_version: '#{RUBY_VERSION}', condition: :eq, message: '#{message}' }"
    RemindMe::Reminder::RubyVersionReminder.build_from(parse_string(comment_string), source_location)
  end

  def create_condition_not_met_reminder(message, source_location)
    comment_string = "{ ruby_version: '#{RUBY_VERSION}', condition: :gt, message: '#{message}' }"
    RemindMe::Reminder::RubyVersionReminder.build_from(parse_string(comment_string), source_location)
  end

  def parse_string(to_be_parsed)
    buffer = Parser::Source::Buffer.new(to_be_parsed)
    buffer.raw_source = to_be_parsed
    RemindMe::Runner.silent_parser.parse(buffer)
  end

  def location(line_number)
    "dummy/location/string:#{line_number}"
  end
end