# frozen_string_literal: true

require 'spec_helper'
require 'remind_me/reminder/generator'
require 'remind_me/reminder/invalid_reminder'

RSpec.describe RemindMe::Reminder::Generator do

  let(:dummy_source_location) { '/dummy/source/location:7:7' }
  let(:existing_reminder_processors) do
    [
      RemindMe::Reminder::MissingGemReminder,
      RemindMe::Reminder::RubyVersionReminder,
      RemindMe::Reminder::GemVersionReminder
    ]
  end

  # prevent mocks from leaking into other examples
  around(:each) do |example|
    original_processors = described_class.instance_variable_get('@registered_reminders').dup
    example.run
    described_class.instance_variable_set('@registered_reminders', original_processors)
  end

  describe '.register' do
    it 'adds class provided to set of registered reminder processors' do
      processor_double = double(:processor_class)
      described_class.register(processor_double)
      expected = described_class.registered_reminders << processor_double
      expect(described_class.registered_reminders).to match_array(expected)
    end
  end

  describe '.registered_reminders' do
    it 'has predefined set of reminder processors' do
      expect(described_class.registered_reminders).to match_array(existing_reminder_processors)
    end

    it 'creates a duplicate of registered_reminders set when accessed' do
      predefined_reminders = described_class.registered_reminders
      predefined_reminders << 'Should not get to set'
      expect(described_class.registered_reminders).to match_array(existing_reminder_processors)
    end
  end

  describe '.generate' do
    it 'creates invalid reminder as comment is un-parsable' do
      parser = RemindMe::Runner.silent_parser
      processed = described_class.generate(dummy_source_location, '{)', parser)
      expect(processed.size).to eq(1)
      expect(processed.first.class).to eq(RemindMe::Reminder::InvalidReminder)
      expect(processed.first.message).to eq('REMIND_ME comment in /dummy/source/location:7:7: unable to parse, message: unexpected token tRPAREN')
    end

    it 'creates invalid reminder as hash is not processable by any known reminder processor' do
      parser = RemindMe::Runner.silent_parser
      random_hash = "{ '#{rand(1000)}' => '#{rand(1000)}' }"
      processed = described_class.generate(dummy_source_location, random_hash, parser)
      expect(processed.size).to eq(1)
      expect(processed.first.class).to eq(RemindMe::Reminder::InvalidReminder)
      expect(processed.first.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: found '#{random_hash}' but it was not applicable to any known reminder processors")
    end

    it 'creates reminder, recognised by just one reminder processor' do
      processors_and_valid_comments = existing_reminder_processors.zip([
       "{ missing_gem: 'some_gem' }",
       "{ ruby_version: '2.4' }",
       "{ gem: 'parser', version: '3.0.2.0', condition: 'gte' }"
      ])
      processors_and_valid_comments.each do |processor, valid_comment|
        parser = RemindMe::Runner.silent_parser
        processed = described_class.generate(dummy_source_location, valid_comment, parser)
        expect(processed.size).to eq(1)
        expect(processed.first.class).to eq(processor)
      end
    end

    it 'creates reminder, recognised multiple reminder processor' do
      matches_any_comment_processor = double(:processor_class)
      matches_any_comment_processor_result = double(:reminder)
      described_class.register(matches_any_comment_processor)
      processors_and_valid_comments = existing_reminder_processors.zip([
       "{ missing_gem: 'some_gem' }",
       "{ ruby_version: '2.4' }",
       "{ gem: 'parser', version: '3.0.2.0', condition: 'gte' }"
     ])
      allow(matches_any_comment_processor).to receive(:applicable_to_ast?).and_return(true)
      allow(matches_any_comment_processor).to receive(:build_from).and_return(matches_any_comment_processor_result)
      processors_and_valid_comments.each do |processor, valid_comment|
        parser = RemindMe::Runner.silent_parser
        processed = described_class.generate(dummy_source_location, valid_comment, parser)
        expect(processed.size).to eq(2)
        # one will be proper reminder, other one is double
        array_with_proper_reminder = processed.select { |reminder| reminder.class == processor }
        array_with_reminder_double = processed.select { |reminder| reminder == matches_any_comment_processor_result }
        expect(array_with_proper_reminder.size).to eq(1)
        expect(array_with_reminder_double.size).to eq(1)
        expect(array_with_reminder_double).not_to match_array(array_with_proper_reminder)
      end
    end
  end

end