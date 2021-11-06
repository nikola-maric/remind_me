# frozen_string_literal: true

require_relative '../reminder/invalid_reminder'

module RemindMe
  module Utils
    module HashASTManipulations

      # Will look for string/symbol keys with specified names in the comment, and if all are found, will return true
      def apply_to_hash_with(key_values)
        # Method for determining if we should consider given reminder for this AST
        define_singleton_method('applicable_to?') do |ast|
          ast.type == :hash && key_values.all? { |key_value| key_present?(ast, key_value) }
        end
        # Building a Reminder from AST, creating invalid one if any of validations returns any non-nil value
        define_singleton_method('build_from') do |reminder_comment_ast, source_location|
          create_reminder_from_ast(reminder_comment_ast, source_location)
        end
        key_values.each do |key|
          create_hash_value_accessor_method(key) unless singleton_method_defined?("hash_ast_#{key}_value")
        end
      end

      def create_reminder_from_ast(reminder_comment_ast, source_location)
        # We first perform AST validation
        ast_validation_errors = singleton_methods.select { |method| method.to_s.start_with?('validate_hash_ast_') }
                                                 .map { |method| send(method, reminder_comment_ast, source_location) }
                                                 .compact
        if ast_validation_errors.empty?
          # AST looks good, now we perform reminder-specific validations
          reminder = new(reminder_comment_ast, source_location)
          validation_errors = reminder.validation_errors
          if validation_errors.empty?
            reminder
          else
            RemindMe::Reminder::InvalidReminder.new(source_location, validation_errors.join(';'))
          end
        else
          RemindMe::Reminder::InvalidReminder.new(source_location, ast_validation_errors.join(';'))
        end
      end

      def validate_hash_ast(key:, value_types:, **options)
        @hash_ast_default_values ||= {}
        @hash_ast_default_values[key] = options[:default_value] if options.key?(:default_value)
        create_hash_value_accessor_method(key) unless singleton_method_defined?("hash_ast_#{key}_value")
        define_singleton_method("validate_hash_ast_#{key}") do |ast, source_location|
          return "REMIND_ME comment in #{source_location} is not a Hash" unless ast.type == :hash

          pair = ast_hash_pair(ast, key)
          # Pair was not found...
          if pair.nil?
            # ... and we don't have default value set for it
            unless @hash_ast_default_values.key?(key)
              "REMIND_ME comment in #{source_location}: value for '#{key}' could not be found, key needs to be "\
              "either String or Symbol. If not set 'default_value' can be used, but that one was not given as well"
            end
          # Pair was found...
          else
            # ... but it does not have proper value type
            unless valid_hash_ast_value?(pair, value_types)
              "REMIND_ME comment in #{source_location}: value under specified key '#{key}' does not have allowed "\
              "type (it has '#{hash_ast_pair_value_type(pair)}'), allowed types are #{value_types}"
            end
          end
        end
      end

      def create_hash_value_accessor_method(key)
        define_singleton_method("hash_ast_#{key}_value") do |ast|
          value = hash_ast_pair_value(ast_hash_pair(ast, key))
          if (value.nil? || value == '') && @hash_ast_default_values.key?(key)
            @hash_ast_default_values[key]
          else
            value
          end
        end
      end

      def singleton_method_defined?(method_name)
        singleton_methods.any? { |method| method.to_s == method_name }
      end

      def ast_hash_pair(hash_ast, key_value)
        children_of_type(hash_ast, :pair).find { |pair| valid_hash_ast_key?(pair, key_value) }
      end

      def key_present?(reminder_comment_ast, key_value)
        children_of_type(reminder_comment_ast, :pair).any? { |pair| valid_hash_ast_key?(pair, key_value) }
      end

      def children_of_type(reminder_comment_ast, type)
        reminder_comment_ast.children.select { |child| child.type.to_s == type.to_s }
      end

      # key is either a symbol or string
      def valid_hash_ast_key?(ast_pair, key_value)
        key = ast_pair.children.first
        %i[sym str].include?(key.type) && key_value.to_s == key.to_a.first.to_s
      end

      def valid_hash_ast_value?(ast_pair, allowed_types)
        value = ast_pair.children[1]
        allowed_types.include?(value.type)
      end

      def hash_ast_pair_value_type(ast_pair)
        ast_pair.children[1].type
      end

      def hash_ast_pair_value(ast_pair)
        return nil if ast_pair.nil? || ast_pair.children.nil? || ast_pair.children.size != 2

        ast_pair.children[1].to_a.first
      end
    end
  end
end
