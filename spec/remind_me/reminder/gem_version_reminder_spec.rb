# frozen_string_literal: true

require 'spec_helper'
require 'remind_me/reminder/gem_version_reminder'

RSpec.describe RemindMe::Reminder::GemVersionReminder do

  let(:dummy_location) { '/dummy/source/location:7:7' }
  let(:installed_gem) { 'parser' }
  let(:gem_current_version) { '3.0.2.0' }
  let(:gem_greater_version) { '4' }
  let(:gem_lower_version) { '2' }

  describe '#applicable_to_ast?' do
    it 'returns true because `gem` is present, as string' do
      comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: '2.4.2', 'condition' => 'gt', message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(true)
    end
    it 'returns true because `gem` is present, as symbol' do
      comment_ast = parse_string("{ gem: :#{installed_gem},  version: '2.4.2', 'condition' => 'gt', message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(true)
    end
    it 'returns false because `gem` is present, but not as string or symbol' do
      comment_ast = parse_string("{ gem => :#{installed_gem},  version: '2.4.2', 'condition' => 'gt', message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(false)
    end
    it 'returns false because `gem` is not present' do
      comment_ast = parse_string("{ '_gem' => :#{installed_gem},  version: '2.4.2', 'condition' => 'gt', message: 'Message 8'}")
      expect(described_class.applicable_to_ast?(comment_ast)).to eq(false)
    end
  end

  describe 'ast validations' do
    context 'version validations' do
      it 'returns validation error because comment is not a hash' do
        comment_ast = parse_string('exit(1)')
        expect(described_class.validate_hash_ast_version(comment_ast, dummy_location))
          .to eq('REMIND_ME comment in /dummy/source/location:7:7 is not a Hash')
      end
      it 'returns validation error because version is given, but key is not string or symbol' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version => 2, 'condition' => 'gt', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_version(comment_ast, dummy_location))
          .to eq(
            "REMIND_ME comment in /dummy/source/location:7:7: value for 'version' could not be found, key needs to "\
            "be either String or Symbol. If not set 'default_value' can be used, but that one was not given as well"
          )
      end
      it 'returns validation error because version is given, but value is not string' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: 2, 'condition' => 'gt', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_version(comment_ast, dummy_location))
          .to eq(
            "REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'version' does not have "\
            "allowed type (it has 'int'), allowed types are [:str]"
          )
      end
      it 'does not return validation error because proper values have been set' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: '#{gem_lower_version}', 'condition' => 'gt', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_version(comment_ast, dummy_location)).to eq(nil)
      end
    end

    context 'message validations' do
      it 'returns validation error because comment is not a hash' do
        comment_ast = parse_string('exit(1)')
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location))
          .to eq('REMIND_ME comment in /dummy/source/location:7:7 is not a Hash')
      end
      it 'returns nil because key is not string or symbol, but we have default value' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version => '2', 'condition' => 'gt', message => 'Message 8'}")
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location)).to eq(nil)
      end
      it 'returns validation error because message is given, but value is not string' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: '#{gem_lower_version}', 'condition' => 'gt', message: 2}")
        expect(described_class.validate_hash_ast_message(comment_ast, dummy_location))
          .to eq(
            "REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'message' does not have "\
            "allowed type (it has 'int'), allowed types are [:str]"
          )
      end
      it 'does not return validation error because proper values have been set' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: '#{gem_lower_version}', 'condition' => 'gt', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_version(comment_ast, dummy_location)).to eq(nil)
      end
    end

    context 'condition validations' do
      it 'returns validation error because comment is not a hash' do
        comment_ast = parse_string('exit(1)')
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location))
          .to eq('REMIND_ME comment in /dummy/source/location:7:7 is not a Hash')
      end
      it 'returns nil because key is not string or symbol, but we have default value' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version => '2', condition => 'gt', 'message' => 'Message 8'}")
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location)).to eq(nil)
      end
      it 'returns validation error because condition is given as string, but value is not string or symbol' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: '#{gem_lower_version}', 'condition' => 2, message: '2'}")
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location))
          .to eq(
            "REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'condition' does not have "\
            "allowed type (it has 'int'), allowed types are [:sym, :str]"
          )
      end
      it 'does not return validation error because proper values have been set (from AST perspective) - string' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: '#{gem_lower_version}', 'condition' => 'bla', message: 'Message 8'}")
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location)).to eq(nil)
      end
      it 'does not return validation error because proper values have been set (from AST perspective) - symbol' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: '#{gem_lower_version}', condition: :bla, message: 'Message 8'}")
        expect(described_class.validate_hash_ast_condition(comment_ast, dummy_location)).to eq(nil)
      end
    end
  end

  describe 'getting values from AST (reminder created must be valid)' do
    context 'getting gem values' do
      it 'gets value because key is string' do
        comment_ast = parse_string("{ 'gem' => :#{installed_gem},  version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_gem).to eq(installed_gem.to_sym)
      end
      it 'gets value because key is symbol' do
        comment_ast = parse_string("{ gem: :#{installed_gem},  version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_gem).to eq(installed_gem.to_sym)
      end
    end

    context 'getting version values' do
      it 'gets value because key is string' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  'version' => '2', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_version).to eq('2')
      end
      it 'gets value because key is symbol' do
        comment_ast = parse_string("{ gem: '#{installed_gem}',  version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_version).to eq('2')
      end
      it 'gets empty string because value of hash is empty string and there are no default values' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  version: '', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_version).to eq('')
      end
    end

    context 'getting condition values' do
      it 'gets default value because value of hash is empty string' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  version: '#{gem_lower_version}', condition: '', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_condition).to eq(:eq)
      end
      it 'gets default value because key/value pair is missing' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_condition).to eq(:eq)
      end
      it 'gets value associated' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', condition: :gt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_condition).to eq(:gt)
      end
    end

    context 'getting message values' do
      it 'gets value because key is string, value is string' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  'version' => '2', 'condition' => :gt, 'message' => 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Message 8')
      end
      it 'gets value because key is symbol, value is string' do
        comment_ast = parse_string("{ gem: '#{installed_gem}',  version: '#{gem_lower_version}', 'condition' => :gt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Message 8')
      end
      it 'gets default value because value of hash is empty string' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  version: '#{gem_lower_version}', 'condition' => :gt, message: ''}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
      it 'gets default value because key/value pair is missing' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', 'condition' => :gt }")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
      it 'gets default value because message key is not string/symbol, so we effectively can\'t find valid pair' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', 'version' => '2', 'condition' => :gt, message => 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.hash_message).to eq('Condition met!')
      end
    end
  end

  describe '#build_from' do
    context 'values are not valid so invalid reminder is returned' do
      it 'gem value is nil' do
        comment_ast = parse_string("{ 'gem' => nil,  version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'gem' does not have allowed type (it has 'nil'), allowed types are [:str, :sym]")
      end
      it 'gem value is empty string, therefore not installed' do
        comment_ast = parse_string("{ 'gem' => '',  version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7 mentions '' gem, but that gem is not installed")
      end
      it 'gem key is not string or symbol' do
        comment_ast = parse_string("{ gem => '#{installed_gem}', 'version' => '', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value for 'gem' could not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one was not given as well")
      end
      it 'gem value is not a string or symbol' do
        comment_ast = parse_string("{ 'gem' => 42, version: '1.0', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'gem' does not have allowed type (it has 'int'), allowed types are [:str, :sym]")
      end
      it 'version is not a string' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  version: nil, condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'version' does not have allowed type (it has 'nil'), allowed types are [:str]")
      end
      it 'version key/value pair is missing entirely' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value for 'version' could not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one was not given as well")
      end
      it 'version key is not string/symbol' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version => '', condition: :lt, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value for 'version' could not be found, key needs to be either String or Symbol. If not set 'default_value' can be used, but that one was not given as well")
      end
      it 'condition (string key) value is not one of predefined ones' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  'version' => '2', 'condition' => :bla, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment on /dummy/source/location:7:7 has invalid condition: bla, only lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)")
      end
      it 'condition (symbol key) value is not one of pre-defiend ones' do
        comment_ast = parse_string("{ gem: '#{installed_gem}',  version: '#{gem_lower_version}', condition: :bla, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment on /dummy/source/location:7:7 has invalid condition: bla, only lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)")
      end
      it 'condition value is nil' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  version: '#{gem_lower_version}', condition: nil, message: 'Message 8'}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'condition' does not have allowed type (it has 'nil'), allowed types are [:sym, :str]")
      end
      it 'message value is nil' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}',  version: '#{gem_lower_version}', 'condition' => :gt, message: nil}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'message' does not have allowed type (it has 'nil'), allowed types are [:str]")
      end
      it 'message value is not a string' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', 'condition' => :gt, message: 42}")
        subject = described_class.build_from(comment_ast, dummy_location)
        expect(subject.class).to eq(RemindMe::Reminder::InvalidReminder)
        expect(subject.message).to eq("REMIND_ME comment in /dummy/source/location:7:7: value under specified key 'message' does not have allowed type (it has 'int'), allowed types are [:str]")
      end
    end
  end

  describe 'reminder validations' do
    # No need to check case when key/value pair is entirely missing, it means this reminder will not be invoked at all
    context 'returns validation error because gem is not installed' do
      it 'creates validation message because specified gem value is nil' do
        comment_ast = parse_string("{ 'gem' => nil, version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array(
          [
            "REMIND_ME comment in dummy_code_source_location mentions '' gem, but that gem is not installed"
          ]
        )
      end
      it 'creates validation message because specified gem value is blank string' do
        comment_ast = parse_string("{ 'gem' => '', version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array(
          [
                  "REMIND_ME comment in dummy_code_source_location mentions '' gem, but that gem is not installed"
                ]
        )
      end
      it 'creates validation message because specified gem is not installed' do
        comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array(
          [
            "REMIND_ME comment in dummy_code_source_location mentions 'non-existent-gem' gem, but that gem is not installed"
          ]
        )
      end
      it 'returns empty array because gem is installed' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_current_version}', condition: :lt, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to eq([])
      end
    end
    context 'supplied condition is not valid' do
      it 'returns validation error because supplied condition is not valid' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_current_version}', condition: :bla, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array([
          "REMIND_ME comment on dummy_code_source_location has invalid condition: bla, only lt, lte, gt, gte, eq "\
          'are possible, or you can omit it entirely (it will default to eq)'
        ])
      end
    end
    context 'supplied version is not valid' do
      it 'returns validation error because supplied version is not valid' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: 'not-a-version-string', condition: :lt, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.validation_errors).to match_array([
          "REMIND_ME comment in dummy_code_source_location mentions '#{installed_gem}' gem, but version specified: "\
          "'not-a-version-string' is not proper version string"
        ])
      end
    end
  end

  describe '#conditions_met?' do
    context 'version value is blank/nil, searching for any version' do
      it 'returns false because gem is not installed and version value is nil' do
        comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: nil, condition: :eq, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.conditions_met?).to eq(false)
      end
      it 'returns false because gem is not installed and version value is blank' do
        comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: '', condition: :eq, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.conditions_met?).to eq(false)
      end
      it 'returns false because gem is not installed and version key/value pair is missing' do
        comment_ast = parse_string("{ 'gem' => 'non-existent-gem', condition: :eq, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.conditions_met?).to eq(false)
      end
      it 'returns false because gem is not installed and version key is not valid' do
        comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version => '2', condition: :eq, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.conditions_met?).to eq(false)
      end
      it 'returns true because gem is not installed and version value is nil' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: nil, condition: :eq, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.conditions_met?).to eq(true)
      end
      it 'returns true because gem is not installed and version value is blank' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '', condition: :eq, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.conditions_met?).to eq(true)
      end
      it 'returns true because gem is not installed and version key/value pair is missing' do
        comment_ast = parse_string("{ 'gem' => '#{installed_gem}', condition: :eq, message: 'Message 8'}")
        subject = described_class.new(comment_ast, 'dummy_code_source_location')
        expect(subject.conditions_met?).to eq(true)
      end
    end

    context 'version is specified properly' do
      context 'using :lt comparison' do
        it 'returns false because gem is not installed' do
          comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: '#{gem_greater_version}', condition: :lt, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns false because installed gem version is same as target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_current_version}', condition: :lt, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns false because installed gem version is greater than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', condition: :lt, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because installed gem version is less than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_greater_version}', condition: :lt, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
      end
      context 'using :lte comparison' do
        it 'returns false because gem is not installed' do
          comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: '#{gem_greater_version}', condition: :lte, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because installed gem version is same as target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_current_version}', condition: :lte, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because installed gem version is greater than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', condition: :lte, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because installed gem version is less than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_greater_version}', condition: :lte, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
      end
      context 'using :eq comparison' do
        it 'returns false because gem is not installed' do
          comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: '#{gem_greater_version}', condition: :eq, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because installed gem version is same as target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_current_version}', condition: :eq, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because installed gem version is greater than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', condition: :eq, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns false because installed gem version is less than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_greater_version}', condition: :eq, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
      end
      context 'using :gte comparison' do
        it 'returns false because gem is not installed' do
          comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: '#{gem_greater_version}', condition: :gte, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because installed gem version is same as target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_current_version}', condition: :gte, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns true because installed gem version is greater than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', condition: :gte, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because installed gem version is less than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_greater_version}', condition: :gte, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
      end
      context 'using :gt comparison' do
        it 'returns false because gem is not installed' do
          comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: '#{gem_greater_version}', condition: :gt, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns false because installed gem version is same as target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_current_version}', condition: :gt, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because installed gem version is greater than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', condition: :gt, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because installed gem version is less than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_greater_version}', condition: :gt, message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
      end
      context 'using default :eq comparison' do
        it 'returns false because gem is not installed' do
          comment_ast = parse_string("{ 'gem' => 'non-existent-gem', version: '#{gem_greater_version}', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because installed gem version is same as target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_current_version}', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(true)
        end
        it 'returns false because installed gem version is greater than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_lower_version}', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
        it 'returns true because installed gem version is less than target version' do
          comment_ast = parse_string("{ 'gem' => '#{installed_gem}', version: '#{gem_greater_version}', message: 'Message 8'}")
          subject = described_class.new(comment_ast, 'dummy_code_source_location')
          expect(subject.conditions_met?).to eq(false)
        end
      end
    end
  end

  def parse_string(to_be_parsed)
    buffer = Parser::Source::Buffer.new(to_be_parsed)
    buffer.raw_source = to_be_parsed
    RemindMe::Runner.silent_parser.parse(buffer)
  end
end