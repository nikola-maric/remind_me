# frozen_string_literal: true

require 'parser/current'
require 'find'

require_relative 'version'
require_relative 'bail_out'
require_relative 'reminder/generator'
require_relative 'utils/logger'
require_relative 'utils/result_printer'

module RemindMe
  class Runner
    include BailOut
    include Utils::Logger

    attr_reader :parser

    def initialize
      @parser = Parser::CurrentRuby.new
      parser.diagnostics.consumer = ->(_message) {  }
      parser.diagnostics.ignore_warnings = true
    end

    def check_reminders(check_path: '.')
      log_info "Checking #{check_path} for any REMIND_ME comments..."
      all_reminders = collect_reminders(check_path)
      Utils::ResultPrinter.new(all_reminders).print_results
    end

    def collect_reminders(parse_path)
      files = collect_ruby_files(parse_path)
      bail_out!('Need something to parse!') if files.empty?
      log_info "Found #{files.size} ruby files"
      raw_comments = collect_relevant_comments(files)
      raw_comments.flat_map { |raw_comment| RemindMe::Reminder::Generator.generate(raw_comment[0], raw_comment[1], parser) }
    end

    private

    def collect_relevant_comments(files)
      files.flat_map { |file| all_file_comments(file) }
           .map { |x| [x.location.expression.to_s, x.text.split('REMIND_ME:', 2)] }
           .select { |x| x[1].size == 2 }
           .map { |x| [x[0], x[1][1].split("\n").first] }
    end

    def all_file_comments(file)
      parser.reset
      source = File.read(file).force_encoding(parser.default_encoding)
      buffer = Parser::Source::Buffer.new(file)
      buffer.source = source
      parser.parse_with_comments(buffer).last
    end

    def collect_ruby_files(parse_path)
      files = []
      if File.directory?(parse_path)
        Find.find(parse_path) do |path|
          files << path if path.end_with? '.rb'
        end
      elsif parse_path.end_with? '.rb'
        files << parse_path
      end
      files
    end
  end
end

