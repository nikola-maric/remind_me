# frozen_string_literal: true
require 'spec_helper'

RSpec.describe RemindMe::Utils::Logger do

  class DummyLoggerUser
    include RemindMe::Utils::Logger
  end

  subject { DummyLoggerUser.new }

  describe '#log_info' do
    it 'uses Rails logger when Rails is defined' do
      allow(subject).to receive(:rails_being_used?).and_return(true)
      expect(subject).to receive(:log_with_rails).with(subject.green('message'), :info)
      subject.log_info('message')
    end
    it 'prints to stout when Rails is not defined' do
      allow(subject).to receive(:rails_being_used?).and_return(false)
      expect(subject).to receive(:puts).with(subject.green('message'))
      subject.log_info('message')
    end
  end

  describe '#log_error' do
    it 'uses Rails logger when Rails is defined' do
      allow(subject).to receive(:rails_being_used?).and_return(true)
      expect(subject).to receive(:log_with_rails).with(subject.red('message'), :error)
      subject.log_error('message')
    end
    it 'prints to stout when Rails is not defined' do
      allow(subject).to receive(:rails_being_used?).and_return(false)
      expect(subject).to receive(:puts).with(subject.red('message'))
      subject.log_error('message')
    end
  end


end