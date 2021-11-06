# frozen_string_literal: true
require 'spec_helper'
require 'erb'

RSpec.describe RemindMe::Runner do

  subject { described_class.new }

  # GEM VERSION REMINDER - single line comments

  let(:gem_version_single_line_error_messages) do
    [
      "REMIND_ME comment in spec/testing_grounds/single_line/gem_version_reminder.rb:8:1: value for 'version' could "\
      "not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one "\
      'was not given as well',
      'REMIND_ME comment in spec/testing_grounds/single_line/gem_version_reminder.rb:23:1: unable to parse, '\
      'message: unexpected token $end',
      "REMIND_ME comment in spec/testing_grounds/single_line/gem_version_reminder.rb:26:1: found ' exit 1' but it was "\
      'not applicable to any known reminder processors',
      'REMIND_ME comment in spec/testing_grounds/single_line/gem_version_reminder.rb:29:1: value under specified '\
      "key 'gem' does not have allowed type (it has 'send'), allowed types are [:str, :sym]",
      "REMIND_ME comment in spec/testing_grounds/single_line/gem_version_reminder.rb:32:1 mentions '' gem, but that "\
      'gem is not installed',
      'REMIND_ME comment in spec/testing_grounds/single_line/gem_version_reminder.rb:35:1: value under specified '\
      "key 'gem' does not have allowed type (it has 'nil'), allowed types are [:str, :sym]",
      'REMIND_ME comment on spec/testing_grounds/single_line/gem_version_reminder.rb:41:1 has invalid condition: '\
      'bla, only lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)'
    ]
  end

  let(:gem_version_single_line_condition_met_messages) do
    [
      'Message 1 at spec/testing_grounds/single_line/gem_version_reminder.rb:2:1',
      'Message 2 at spec/testing_grounds/single_line/gem_version_reminder.rb:5:1',
      'Message 4 at spec/testing_grounds/single_line/gem_version_reminder.rb:11:1',
      'Message 5 at spec/testing_grounds/single_line/gem_version_reminder.rb:14:1',
      'Condition met! at spec/testing_grounds/single_line/gem_version_reminder.rb:38:1'
    ]
  end

  let(:gem_version_single_line_condition_not_met_messages) do
    [
      'Message 6 at spec/testing_grounds/single_line/gem_version_reminder.rb:17:1',
      'Message 7 at spec/testing_grounds/single_line/gem_version_reminder.rb:20:1'
    ]
  end

  # GEM VERSION REMINDER - multi line comments

  let(:gem_version_multi_line_error_messages) do
    [
      "REMIND_ME comment in spec/testing_grounds/multi_line/gem_version_reminder.rb:9:1: value for 'version' could "\
      "not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one "\
      'was not given as well',
      'REMIND_ME comment in spec/testing_grounds/multi_line/gem_version_reminder.rb:29:1: unable to parse, '\
      'message: unexpected token $end',
      "REMIND_ME comment in spec/testing_grounds/multi_line/gem_version_reminder.rb:33:1: found ' exit 1' but it was "\
      'not applicable to any known reminder processors',
      'REMIND_ME comment in spec/testing_grounds/multi_line/gem_version_reminder.rb:37:1: value under specified '\
      "key 'gem' does not have allowed type (it has 'send'), allowed types are [:str, :sym]",
      "REMIND_ME comment in spec/testing_grounds/multi_line/gem_version_reminder.rb:41:1 mentions '' gem, but that "\
      'gem is not installed',
      'REMIND_ME comment in spec/testing_grounds/multi_line/gem_version_reminder.rb:45:1: value under specified '\
      "key 'gem' does not have allowed type (it has 'nil'), allowed types are [:str, :sym]",
      'REMIND_ME comment on spec/testing_grounds/multi_line/gem_version_reminder.rb:53:1 has invalid condition: '\
      'bla, only lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)'
    ]
  end

  let(:gem_version_multi_line_condition_met_messages) do
    [
      'Message 1 at spec/testing_grounds/multi_line/gem_version_reminder.rb:1:1',
      'Message 2 at spec/testing_grounds/multi_line/gem_version_reminder.rb:5:1',
      'Message 4 at spec/testing_grounds/multi_line/gem_version_reminder.rb:13:1',
      'Message 5 at spec/testing_grounds/multi_line/gem_version_reminder.rb:17:1',
      'Condition met! at spec/testing_grounds/multi_line/gem_version_reminder.rb:49:1'
    ]
  end

  let(:gem_version_multi_line_condition_not_met_messages) do
    [
      'Message 6 at spec/testing_grounds/multi_line/gem_version_reminder.rb:21:1',
      'Message 7 at spec/testing_grounds/multi_line/gem_version_reminder.rb:25:1'
    ]
  end

  # MISSING GEM REMINDER - single line comments

  let(:missing_gem_single_line_error_messages) do
    [
      'REMIND_ME comment in spec/testing_grounds/single_line/missing_gem_reminder.rb:9:1: unable to parse, '\
      'message: unexpected token $end',
      "REMIND_ME comment in spec/testing_grounds/single_line/missing_gem_reminder.rb:12:1: found ' exit(1)' but it "\
      'was not applicable to any known reminder processors'
    ]
  end

  let(:missing_gem_single_line_condition_met_messages) do
    [
      'Message 1 at spec/testing_grounds/single_line/missing_gem_reminder.rb:3:1'
    ]
  end

  let(:missing_gem_single_line_condition_not_met_messages) do
    [
      'Condition met! at spec/testing_grounds/single_line/missing_gem_reminder.rb:15:1',
      'Message 2 at spec/testing_grounds/single_line/missing_gem_reminder.rb:6:1'
    ]
  end

  # MISSING GEM REMINDER - multi line comments

  let(:missing_gem_multi_line_error_messages) do
    [
      'REMIND_ME comment in spec/testing_grounds/multi_line/missing_gem_reminder.rb:9:1: unable to parse, '\
      'message: unexpected token $end',
      "REMIND_ME comment in spec/testing_grounds/multi_line/missing_gem_reminder.rb:13:1: found ' exit(1)' but it "\
      'was not applicable to any known reminder processors'
    ]
  end

  let(:missing_gem_multi_line_condition_met_messages) do
    [
      'Message 1 at spec/testing_grounds/multi_line/missing_gem_reminder.rb:1:1'
    ]
  end

  let(:missing_gem_multi_line_condition_not_met_messages) do
    [
      'Message 2 at spec/testing_grounds/multi_line/missing_gem_reminder.rb:5:1',
      'Condition met! at spec/testing_grounds/multi_line/missing_gem_reminder.rb:17:1'
    ]
  end

  # RUBY VERSION REMINDER - single line comments

  let(:ruby_version_single_line_error_messages) do
    [
      'REMIND_ME comment in spec/testing_grounds/single_line/ruby_version_reminder.rb:47:1: unable to parse, '\
      'message: unexpected token $end',
      "REMIND_ME comment in spec/testing_grounds/single_line/ruby_version_reminder.rb:50:1: found ' exit 1' but "\
      'it was not applicable to any known reminder processors',
      'REMIND_ME comment on spec/testing_grounds/single_line/ruby_version_reminder.rb:56:1 has invalid condition: '\
      'bla, only lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)'
    ]
  end

  let(:ruby_version_single_line_condition_met_messages) do
    [
      'Message 1 at spec/testing_grounds/single_line/ruby_version_reminder.rb:2:1',
      'Message 2 at spec/testing_grounds/single_line/ruby_version_reminder.rb:5:1',
      'Message 3 at spec/testing_grounds/single_line/ruby_version_reminder.rb:8:1',
      'Message 4 at spec/testing_grounds/single_line/ruby_version_reminder.rb:11:1',
      'Message 5 at spec/testing_grounds/single_line/ruby_version_reminder.rb:14:1',
      'Message 8 at spec/testing_grounds/single_line/ruby_version_reminder.rb:23:1',
      'Message 9 at spec/testing_grounds/single_line/ruby_version_reminder.rb:26:1',
      'Message 10 at spec/testing_grounds/single_line/ruby_version_reminder.rb:29:1',
      'Message 15 at spec/testing_grounds/single_line/ruby_version_reminder.rb:44:1',
      'Condition met! at spec/testing_grounds/single_line/ruby_version_reminder.rb:53:1'
    ]
  end

  let(:ruby_version_single_line_condition_not_met_messages) do
    [
      'Message 6 at spec/testing_grounds/single_line/ruby_version_reminder.rb:17:1',
      'Message 7 at spec/testing_grounds/single_line/ruby_version_reminder.rb:20:1',
      'Message 11 at spec/testing_grounds/single_line/ruby_version_reminder.rb:32:1',
      'Message 12 at spec/testing_grounds/single_line/ruby_version_reminder.rb:35:1',
      'Message 13 at spec/testing_grounds/single_line/ruby_version_reminder.rb:38:1',
      'Message 14 at spec/testing_grounds/single_line/ruby_version_reminder.rb:41:1'
    ]
  end

  # RUBY VERSION REMINDER - multi line comments

  let(:ruby_version_multi_line_error_messages) do
    [
      'REMIND_ME comment in spec/testing_grounds/multi_line/ruby_version_reminder.rb:61:1: unable to parse, '\
      'message: unexpected token $end',
      "REMIND_ME comment in spec/testing_grounds/multi_line/ruby_version_reminder.rb:65:1: found ' exit 1' but "\
      'it was not applicable to any known reminder processors',
      'REMIND_ME comment on spec/testing_grounds/multi_line/ruby_version_reminder.rb:73:1 has invalid condition: '\
      'bla, only lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)'
    ]
  end

  let(:ruby_version_multi_line_condition_met_messages) do
    [
      'Message 1 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:1:1',
      'Message 2 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:5:1',
      'Message 3 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:9:1',
      'Message 4 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:13:1',
      'Message 5 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:17:1',
      'Message 8 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:29:1',
      'Message 9 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:33:1',
      'Message 10 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:37:1',
      'Message 15 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:57:1',
      'Condition met! at spec/testing_grounds/multi_line/ruby_version_reminder.rb:69:1'
    ]
  end

  let(:ruby_version_multi_line_condition_not_met_messages) do
    [
      'Message 6 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:21:1',
      'Message 7 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:25:1',
      'Message 11 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:41:1',
      'Message 12 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:45:1',
      'Message 13 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:49:1',
      'Message 14 at spec/testing_grounds/multi_line/ruby_version_reminder.rb:53:1'
    ]
  end

  describe '.collect_reminders' do

    it 'errors out when no ruby files are found' do
      expect { subject.collect_reminders('spec/testing_grounds/empty_directory') }.to raise_error(RemindMe::BailOut::Error)
    end

    context 'gem version reminders' do
      it 'picks up single line comments properly' do
        gem_version_reminder_expectations('spec/testing_grounds/single_line/gem_version_reminder.rb',
                                          gem_version_single_line_error_messages,
                                          gem_version_single_line_condition_met_messages,
                                          gem_version_single_line_condition_not_met_messages)
      end
      it 'picks up multi line comments properly' do
        gem_version_reminder_expectations('spec/testing_grounds/multi_line/gem_version_reminder.rb',
                                          gem_version_multi_line_error_messages,
                                          gem_version_multi_line_condition_met_messages,
                                          gem_version_multi_line_condition_not_met_messages)
      end
    end

    context 'missing gem reminders' do
      it 'picks up single line comments properly' do
        missing_gem_reminder_expectations('spec/testing_grounds/single_line/missing_gem_reminder.rb',
                                          missing_gem_single_line_error_messages,
                                          missing_gem_single_line_condition_met_messages,
                                          missing_gem_single_line_condition_not_met_messages)
      end
      it 'picks up multi line comments properly' do
        missing_gem_reminder_expectations('spec/testing_grounds/multi_line/missing_gem_reminder.rb',
                                          missing_gem_multi_line_error_messages,
                                          missing_gem_multi_line_condition_met_messages,
                                          missing_gem_multi_line_condition_not_met_messages)
      end
    end

    context 'ruby version reminders' do
      it 'picks up single line comments properly' do
        @current_ruby_version = RUBY_VERSION
        @greater_ruby_version = Gem::Version.new(RUBY_VERSION).bump
        # This gem requires at least 2.4, so this will always be true
        @lower_ruby_version = Gem::Version.new('2.0')
        template = ERB.new(File.read('spec/testing_grounds/single_line/ruby_version_reminder.erb'))
        File.write('spec/testing_grounds/single_line/ruby_version_reminder.rb', template.result(binding))
        ruby_version_reminder_expectations('spec/testing_grounds/single_line/ruby_version_reminder.rb',
                                           ruby_version_single_line_error_messages,
                                           ruby_version_single_line_condition_met_messages,
                                           ruby_version_single_line_condition_not_met_messages)
      end
      it 'picks up multi line comments properly' do
        @current_ruby_version = RUBY_VERSION
        @greater_ruby_version = Gem::Version.new(RUBY_VERSION).bump
        # This gem requires at least 2.4, so this will always be true
        @lower_ruby_version = Gem::Version.new('2.0')
        template = ERB.new(File.read('spec/testing_grounds/multi_line/ruby_version_reminder.erb'))
        File.write('spec/testing_grounds/multi_line/ruby_version_reminder.rb', template.result(binding))
        ruby_version_reminder_expectations('spec/testing_grounds/multi_line/ruby_version_reminder.rb',
                                           ruby_version_multi_line_error_messages,
                                           ruby_version_multi_line_condition_met_messages,
                                           ruby_version_multi_line_condition_not_met_messages)
      end
    end
  end

  def ruby_version_reminder_expectations(file, error_messages, condition_met_messages, condition_not_met_messages)
    collected_reminders = subject.collect_reminders(file)
    valid_condition_met_reminders = collected_reminders.reject { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
                                                       .select(&:conditions_met?)
    valid_condition_not_met_reminders = collected_reminders.reject { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
                                                           .reject(&:conditions_met?)
    invalid_reminders = collected_reminders.select { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
    expect(valid_condition_met_reminders.map(&:message)).to match_array(condition_met_messages)
    expect(valid_condition_not_met_reminders.map(&:message)).to match_array(condition_not_met_messages)
    expect(invalid_reminders.map(&:message))
      .to match_array(error_messages)
  end

  def missing_gem_reminder_expectations(file, error_messages, condition_met_messages, condition_not_met_messages)
    collected_reminders = subject.collect_reminders(file)
    valid_condition_met_reminders = collected_reminders.reject { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
                                                       .select(&:conditions_met?)
    valid_condition_not_met_reminders = collected_reminders.reject { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
                                                           .reject(&:conditions_met?)
    invalid_reminders = collected_reminders.select { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
    expect(valid_condition_met_reminders.map(&:message)).to match_array(condition_met_messages)
    expect(valid_condition_not_met_reminders.map(&:message)).to match_array(condition_not_met_messages)
    expect(invalid_reminders.map(&:message)).to match_array(error_messages)
  end

  def gem_version_reminder_expectations(file, error_messages, condition_met_messages, condition_not_met_messages)
    collected_reminders = subject.collect_reminders(file)
    valid_condition_met_reminders = collected_reminders.reject { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
                                                       .select(&:conditions_met?)
    valid_condition_not_met_reminders = collected_reminders.reject { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
                                                           .reject(&:conditions_met?)
    invalid_reminders = collected_reminders.select { |r| r.is_a?(RemindMe::Reminder::InvalidReminder) }
    expect(valid_condition_met_reminders.map(&:message))
      .to match_array(condition_met_messages)
    expect(valid_condition_not_met_reminders.map(&:message))
      .to match_array(condition_not_met_messages)
    expect(invalid_reminders.map(&:message))
      .to match_array(error_messages)
  end

end
