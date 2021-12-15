# frozen_string_literal: true

require 'parser/current'
require 'find'
require 'parallel/processor_count'
require 'parallel'

require_relative 'version'
require_relative 'bail_out'
require_relative 'reminder/generator'
require_relative 'utils/logger'
require_relative 'utils/result_printer'

module RemindMe
  class Runner
    extend BailOut
    extend Utils::Logger
    extend Parallel::ProcessorCount

    def self.check_reminders(check_path: '.')
      Utils::ResultPrinter.new(collect_reminders(check_path)).print_results
    end

    def self.collect_reminders(path)
      files = relevant_ruby_files(path)
      return if files.empty?

      Parallel.flat_map(in_groups(files, processor_count, false)) do |files|
        parser = silent_parser
        raw_comments = collect_relevant_comments(files, parser)
        raw_comments.flat_map { |raw_comment| RemindMe::Reminder::Generator.generate(raw_comment[0], raw_comment[1], parser) }
      end
    end

    def self.silent_parser
      parser = Parser::CurrentRuby.new
      parser.diagnostics.consumer = ->(_message) {}
      parser.diagnostics.ignore_warnings = true
      parser
    end

    def self.all_file_comments(file, parser)
      parser.reset
      source = File.read(file).force_encoding(parser.default_encoding)
      buffer = Parser::Source::Buffer.new(file)
      buffer.source = source
      parser.parse_with_comments(buffer).last
    end

    def self.collect_relevant_comments(files, parser)
      files.flat_map { |file| all_file_comments(file, parser) }
           .map { |x| [x.location.expression.to_s, x.text.split('REMIND_ME:', 2)] }
           .select { |x| x[1].size == 2 }
           .map { |x| [x[0], x[1][1].split("\n").first] }
    end

    def self.relevant_ruby_files(parse_path)
      Parallel.flat_map(in_groups(collect_ruby_files(parse_path), processor_count, false)) do |files|
        files.select do |file|
          IO.foreach(file).any? { |line| line.include?('REMIND_ME:') }
        end
      end
    end

    def self.collect_ruby_files(parse_path)
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

    def self.in_groups(array, number, fill_with = nil)
      division = array.size.div number
      modulo = array.size % number
      groups = []
      start = 0
      number.times do |index|
        length = division + (modulo.positive? && modulo > index ? 1 : 0)
        groups << last_group = array.slice(start, length)
        last_group << fill_with if fill_with != false && modulo.positive? && length == division
        start += length
      end
      groups
    end

    private_class_method :in_groups,
                         :collect_ruby_files,
                         :collect_relevant_comments
  end
end

