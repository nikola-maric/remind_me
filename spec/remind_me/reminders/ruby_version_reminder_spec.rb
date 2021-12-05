# frozen_string_literal: true

require 'spec_helper'
require 'remind_me/reminder/ruby_version_reminder'

RSpec.describe RemindMe::Reminder::RubyVersionReminder do

  let(:dummy_location) { '/dummy/source/location:7:7' }
  let(:current_ruby_version) { RUBY_VERSION }
  let(:lower_ruby_version) { '1.9' }
  let(:greater_ruby_version) { Gem::Version.new(RUBY_VERSION).bump.to_s }

  describe '#applicable_to_ast?' do
    it 'returns true because `ruby_version` is present, as string' do
      comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(true)
    end
    it 'returns true because `gem` is present, as symbol' do
      comment_ast = parse_string("{ ruby_version: '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(true)
    end
    it 'returns false because `gem` is present, but not as string or symbol' do
      comment_ast = parse_string("{ ruby_version => '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(false)
    end
    it 'returns false because `gem` is not present' do
      comment_ast = parse_string("{ '_ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(false)
    end
  end

  describe 'ast validations' do
    context 'message validations' do
      it 'returns validation error because comment is not a hash' do
        comment_ast = parse_string('exit(1)')
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location))
          .to eq('REMIND_ME comment in /dummy/source/location:7:7 is not a Hash')
      end
      it 'returns nil because key is not string or symbol, but we have default value' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message => 'Message 8'}")
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location)).to eq(nil)
      end
      it 'returns validation error because message is given, but value is not string' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: 2}")
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location))
          .to eq(
            "REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'message' does not have "\
            "allowed type (it has 'int'), allowed types are [:str]"
          )
      end
      it 'does not return validation error because proper values have been set' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location)).to eq(nil)
      end
    end

    context 'condition validations' do
      it 'returns validation error because comment is not a hash' do
        comment_ast = parse_string('exit(1)')
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location))
          .to eq('REMIND_ME comment in /dummy/source/location:7:7 is not a Hash')
      end
      it 'returns nil because key is not string or symbol, but we have default value' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', condition => 'gt', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location)).to eq(nil)
      end
      it 'returns validation error because condition is given as string, but value is not string or symbol' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 2, message: 'Message 8'}")
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location))
          .to eq(
            "REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'condition' does not have "\
            "allowed type (it has 'int'), allowed types are [:sym, :str]"
          )
      end
      it 'does not return validation error because proper values have been set (from AST perspective) - string' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'bla', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location)).to eq(nil)
      end
      it 'does not return validation error because proper values have been set (from AST perspective) - symbol' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => :bla, message: 'Message 8'}")
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location)).to eq(nil)
      end
    end
  end

  describe 'getting values from AST (reminder created must be valid)' do
    context 'getting ruby_version values' do
      it 'gets value because key is string' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_ruby_version).to eq(current_ruby_version)
      end
      it 'gets value because key is symbol' do
        comment_ast = parse_string("{ ruby_version: '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_ruby_version).to eq(current_ruby_version)
      end
    end

    context 'getting condition values' do
      it 'gets default value because value of hash is empty string' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => '', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_condition).to eq(:eq)
      end
      it 'gets default value because key/value pair is missing' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_condition).to eq(:eq)
      end
      it 'gets default value because key is not string/symbol so we effectively can\'t find valid pair' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', condition => 'gt', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_condition).to eq(:eq)
      end
    end

    context 'getting message values' do
      it 'gets value because key is string' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', 'message' => 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Message 8')
      end
      it 'gets default value because value of hash is empty string' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: ''}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
      it 'gets default value because key/value pair is missing' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt' }")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
      it 'gets default value because key is not string/symbol so we effectively can\'t find valid pair' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message => 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
    end
  end

  describe '#build_from' do
    context 'values are not valid so invalid reminder is returned' do
      # ruby version
      it 'value of ruby_version hash is nil and there are no default values' do
        comment_ast = parse_string("{ 'ruby_version' => nil, 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'ruby_version' does not have allowed type (it has 'nil'), allowed types are [:sym, :str]")
      end
      it 'value of ruby_version hash is empty string and there are no default values' do
        comment_ast = parse_string("{ 'ruby_version' => '', 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment on /dummy/source/location:7:7 has blank ruby version, you must specify version string")
      end
      it 'ruby_version key/value pair is missing' do
        comment_ast = parse_string("{ 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value for 'ruby_version' could not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one was not given as well")
      end
      it 'ruby_version key is not string/symbol' do
        comment_ast = parse_string("{ ruby_version => '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value for 'ruby_version' could not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one was not given as well")
      end
      it 'ruby_version hash value has invalid type' do
        comment_ast = parse_string("{ 'ruby_version' => 42, 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'ruby_version' does not have allowed type (it has 'int'), allowed types are [:sym, :str]")
      end
      # condition
      it 'condition (string key) value is not one of predefined ones' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => :bla, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment on /dummy/source/location:7:7 has invalid condition: bla, only lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)")
      end
      it 'condition (string key) value is not one of predefined ones' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', condition: :bla, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment on /dummy/source/location:7:7 has invalid condition: bla, only lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)")
      end
      it 'value of condition hash is nil' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', condition: nil, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'condition' does not have allowed type (it has 'nil'), allowed types are [:sym, :str]")
      end
      it 'condition (string key) value is not string/symbol' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 42, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'condition' does not have allowed type (it has 'int'), allowed types are [:sym, :str]")
      end
      # message
      it 'value of message hash is nil (symbol key)' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: nil}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'message' does not have allowed type (it has 'nil'), allowed types are [:str]")
      end
      it 'value of message hash is nil (string key)' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', 'message' => nil}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'message' does not have allowed type (it has 'nil'), allowed types are [:str]")
      end
      it 'value of message hash is not string' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: 42}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'message' does not have allowed type (it has 'int'), allowed types are [:str]")
      end
    end
  end

  describe 'reminder validations' do
    # No need to check case when key/value pair is entirely missing, it means this reminder will not be invoked at all
    context 'returns validation error because gem is not installed' do
      it 'creates validation message because specified ruby_version value is nil' do
        comment_ast = parse_string("{ 'ruby_version' => nil, 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array(
          [
            'REMIND_ME comment on dummy_code_source_location has blank ruby version, you must specify version string'
          ]
       )
      end
      it 'creates validation message because specified ruby_version value is blank string' do
        comment_ast = parse_string("{ 'ruby_version' => '', 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array(
          [
            'REMIND_ME comment on dummy_code_source_location has blank ruby version, you must specify version string'
          ]
       )
      end
      it 'creates validation message because specified ruby_version is not proper version string' do
        comment_ast = parse_string("{ 'ruby_version' => 'not-a-version-string', 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array(
          [
            "REMIND_ME comment in dummy_code_source_location mentions 'not-a-version-string' ruby version, but "\
            ' that is not a proper version string'
          ]
       )
      end
    end
    context 'supplied condition is not valid' do
      it 'returns validation error because supplied version is not valid' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => :bla, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array([
          'REMIND_ME comment on dummy_code_source_location has invalid condition: bla, only lt, lte, gt, gte, eq '\
          'are possible, or you can omit it entirely (it will default to eq)'
        ])
      end
    end
    context 'everything is valid' do
      it 'returns no validation errors' do
        comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to eq([])
      end
    end
  end

  describe '#conditions_met?' do
    context 'version is specified properly' do
      context 'using :lt comparison' do
        it 'returns false because current ruby version is same as target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'lt', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns false because current ruby version is greater than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{lower_ruby_version}', 'condition' => 'lt', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because current ruby version is less than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{higher_ruby_version}', 'condition' => 'lt', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
      end
      context 'using :lte comparison' do
        it 'returns true because current ruby version is same as target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'lte', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because current ruby version is greater than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{lower_ruby_version}', 'condition' => 'lt', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because current ruby version is less than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{higher_ruby_version}', 'condition' => 'lte', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
      end
      context 'using :eq comparison' do
        it 'returns true because current ruby version is same as target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'eq', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because current ruby version is greater than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{lower_ruby_version}', 'condition' => 'eq', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns false because current ruby version is less than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{higher_ruby_version}', 'condition' => 'eq', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
      end
      context 'using :gte comparison' do
        it 'returns true because current ruby version is same as target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gte', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns true because current ruby version is greater than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{lower_ruby_version}', 'condition' => 'gte', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because current ruby version is less than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{higher_ruby_version}', 'condition' => 'gte', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
      end
      context 'using :gt comparison' do
        it 'returns false because current ruby version is same as target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because current ruby version is greater than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{lower_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because current ruby version is less than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{higher_ruby_version}', 'condition' => 'gt', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
      end
      context 'using default :eq comparison' do
        it 'returns true because current ruby version is same as target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{current_ruby_version}', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because current ruby version is greater than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{lower_ruby_version}', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns false because current ruby version is less than target version' do
          comment_ast = parse_string("{ 'ruby_version' => '#{higher_ruby_version}', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
      end
    end
  end

  def parse_string(to_be_parsed)
    runner = RemindMe::Runner.new
    buffer = Parser::Source::Buffer.new(to_be_parsed)
    buffer.raw_source = to_be_parsed
    runner.parser.parse(buffer)
  end

  def current_ruby_version
    RUBY_VERSION
  end

  def lower_ruby_version
    '2.0'
  end

  def higher_ruby_version
    Gem::Version.new(RUBY_VERSION).bump
  end
end