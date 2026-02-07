# frozen_string_literal: true

RSpec.describe 'RemindMe::Native' do
  before(:each) do
    skip 'Native extension not available' unless REMIND_ME_NATIVE_AVAILABLE
  end

  describe '.scan_for_remind_me_comments' do
    it 'returns empty array for path with no .rb files' do
      result = RemindMe::Native.scan_for_remind_me_comments('spec/testing_grounds/empty_directory')
      expect(result).to eq([])
    end

    it 'returns empty array for non-existent path' do
      result = RemindMe::Native.scan_for_remind_me_comments('spec/testing_grounds/does_not_exist')
      expect(result).to eq([])
    end

    context 'single-line comments' do
      it 'finds all REMIND_ME comments with correct locations' do
        result = RemindMe::Native.scan_for_remind_me_comments(
          'spec/testing_grounds/single_line/missing_gem_reminder.rb'
        )
        expect(result).to be_an(Array)
        expect(result.size).to eq(5)
        result.each do |entry|
          expect(entry).to be_an(Array)
          expect(entry.size).to eq(2)
          expect(entry[0]).to match(/missing_gem_reminder\.rb:\d+:1\z/)
        end
      end
    end

    context 'block comments' do
      it 'reports source location pointing to =begin line' do
        result = RemindMe::Native.scan_for_remind_me_comments(
          'spec/testing_grounds/multi_line/missing_gem_reminder.rb'
        )
        expect(result.size).to eq(5)
        line_nums = result.map { |loc, _| loc.split(':')[-2].to_i }.sort
        # =begin lines in the fixture are at 1, 5, 9, 13, 17
        expect(line_nums).to eq([1, 5, 9, 13, 17])
      end
    end

    context 'parity with Ruby scanner' do
      let(:parser) { RemindMe::Runner.send(:silent_parser) }

      %w[
        spec/testing_grounds/single_line/missing_gem_reminder.rb
        spec/testing_grounds/multi_line/missing_gem_reminder.rb
      ].each do |fixture|
        it "produces identical output to Ruby scanner for #{File.basename(fixture, '.rb')}" do
          rust_results = RemindMe::Native.scan_for_remind_me_comments(fixture).sort_by(&:first)

          parser.reset
          ruby_results = RemindMe::Runner.send(:collect_relevant_comments, [fixture], parser).sort_by(&:first)

          expect(rust_results).to eq(ruby_results)
        end
      end
    end
  end
end
