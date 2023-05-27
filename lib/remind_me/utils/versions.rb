# frozen_string_literal: true
require 'rubygems'

module RemindMe
  module Utils
    module Versions
      INSTALLED_GEMS = Gem::Specification.map { |a| [a.name, a.version] }.to_h

      def compare_version_numbers(target_version, current_version, comparator)
        current_version.__send__(condition_comparators[comparator.to_sym], target_version)
      end

      def gem_version(gem_name)
        INSTALLED_GEMS[gem_name]
      end

      def gem_installed?(gem)
        INSTALLED_GEMS.key?(gem.to_s)
      end

      def valid_condition?(condition)
        condition_comparators.keys.flat_map { |x| [x, x.to_s] }.include?(condition)
      end

      def condition_comparators
        %i[lt lte gt gte eq].zip(%i[< <= > >= ==]).to_h
      end

      def valid_version_string?(version_string)
        Gem::Version.new(version_string)
        true
      rescue ArgumentError => _e
        false
      end

      def invalid_condition_message(source_location, condition)
        "REMIND_ME comment on #{source_location} has invalid condition: #{condition}, only "\
        'lt, lte, gt, gte, eq are possible, or you can omit it entirely (it will default to eq)'
      end
    end
  end
end
