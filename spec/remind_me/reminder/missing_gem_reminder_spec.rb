# frozen_string_literal: true
require 'spec_helper'
require 'remind_me/reminder/missing_gem_reminder'

RSpec.describe RemindMe::Reminder::MissingGemReminder do

  let(:dummy_location) { '/dummy/source/location:7:7' }
  let(:dummy_gem) { 'non_installed_gem' }

  describe '#applicable_to_ast?' do
    it 'returns true because `missing_gem` is present, as string' do
      comment_ast = parse_string("{ 'missing_gem' => :#{dummy_gem}, message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(true)
    end
    it 'returns true because `missing_gem` is present, as symbol' do
      comment_ast = parse_string("{ missing_gem: :#{dummy_gem}, message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(true)
    end
    it 'returns false because `missing_gem` is present, but not as string or symbol' do
      comment_ast = parse_string("{ missing_gem => :#{dummy_gem}, message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(false)
    end
    it 'returns false because `missing_gem` is not present' do
      comment_ast = parse_string("{ '_missing_gem' => :#{dummy_gem}, message: 'Message 8'}")
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
        comment_ast = parse_string("{ 'gem' => :#{dummy_gem},  version => '2', 'condition' => 'gt', message => 'Message 8'}")
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location)).to eq(nil)
      end
      it 'returns validation error because message is given, but value is not string' do
        comment_ast = parse_string("{ 'gem' => :#{dummy_gem},  version: '2', 'condition' => 'gt', message: 2}")
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location))
          .to eq(
            "REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'message' does not have "\
            "allowed type (it has 'int'), allowed types are [:str]"
          )
      end
      it 'does not return validation error because proper values have been set' do
        comment_ast = parse_string("{ 'gem' => :#{dummy_gem},  version: '2', 'condition' => 'gt', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location)).to eq(nil)
      end
    end
  end

  describe 'getting values from AST' do
    context 'getting missing_gem values' do
      it 'gets value because key is string' do
        comment_ast = parse_string("{ 'missing_gem' => :#{dummy_gem}, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_missing_gem).to eq(dummy_gem.to_sym)
      end
      it 'gets value because key is symbol' do
        comment_ast = parse_string("{ missing_gem: :#{dummy_gem}, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_missing_gem).to eq(dummy_gem.to_sym)
      end
      it 'gets empty string because value of hash is empty string and there are no default values' do
        comment_ast = parse_string("{ 'missing_gem' => '', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_missing_gem).to eq('')
      end
    end

    context 'getting message values' do
      it 'gets value because key is string' do
        comment_ast = parse_string("{ 'missing_gem' => 'ast', 'message' => 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Message 8')
      end
      it 'gets value because key is symbol' do
        comment_ast = parse_string("{ 'missing_gem' => 'ast', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Message 8')
      end
      it 'gets default value because value of hash is empty string' do
        comment_ast = parse_string("{ 'missing_gem' => 'ast', 'message' => ''}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
      it 'gets default value because key/value pair is missing' do
        comment_ast = parse_string("{ 'missing_gem' => 'ast' }")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
      it 'gets default value because key is not string/symbol so we effectively can\'t find valid pair' do
        comment_ast = parse_string("{ 'missing_gem' => 'ast', message => 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
    end

    context 'creates invalid reminder because message value is not string' do
      it 'gets default value because value of hash is nil' do
        comment_ast = parse_string("{ 'missing_gem' => 'ast', 'message' => nil}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in #{dummy_location}: value under specified key 'message' does not have allowed type (it has 'nil'), allowed types are [:str]")
      end
      it 'gets nil because key/value pair is missing' do
        comment_ast = parse_string("{ message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value for 'missing_gem' could not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one was not given as well")
      end
      it 'gets nil because key is not string/symbol' do
        comment_ast = parse_string("{ missing_gem => 'ast', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value for 'missing_gem' could not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one was not given as well")
      end
      it 'gets value associated (no validations are involved, raw data is returned)' do
        comment_ast = parse_string("{ 'missing_gem' => 42, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'missing_gem' does not have allowed type (it has 'int'), allowed types are [:sym, :str]")
      end
      it 'gets nil because value of hash is nil and there are no default values' do
        comment_ast = parse_string("{ 'missing_gem' => nil, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'missing_gem' does not have allowed type (it has 'nil'), allowed types are [:sym, :str]")
      end
    end
  end

  describe '#conditions_met?' do
    it 'returns true because gem is not installed (value is nil..not sure why would anyone do this?)' do
      comment_ast = parse_string("{ 'missing_gem' => nil }")
      subject = described_class.new(comment_ast, 'dummy_code_source_location')
      expect(subject.conditions_met?).to eq(true)
    end
    it 'returns true because gem is not installed (value is blank..not sure why would anyone do this?)' do
      comment_ast = parse_string("{ missing_gem: '' }")
      subject = described_class.new(comment_ast, 'dummy_code_source_location')
      expect(subject.conditions_met?).to eq(true)
    end
    it 'returns true because gem is not installed' do
      comment_ast = parse_string("{ missing_gem: 'blaze' }")
      subject = described_class.new(comment_ast, 'dummy_code_source_location')
      expect(subject.conditions_met?).to eq(true)
    end
    it 'returns false because gem is installed' do
      comment_ast = parse_string("{ missing_gem: 'parser' }")
      subject = described_class.new(comment_ast, 'dummy_code_source_location')
      expect(subject.conditions_met?).to eq(false)
    end
  end

  def parse_string(to_be_parsed)
    buffer = Parser::Source::Buffer.new(to_be_parsed)
    buffer.raw_source = to_be_parsed
    RemindMe::Runner.silent_parser.parse(buffer)
  end
end