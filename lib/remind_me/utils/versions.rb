# frozen_string_literal: true

module RemindMe
  module Utils
    module Versions
      INSTALLED_GEMS = Gem::Specification.map { |a| [a.name, a.version] }.to_h

      def compare_version_numbers(target_version, current_version, comparator)
        case comparator.to_sym
        when :lt
          current_version < target_version
        when :lte
          current_version <= target_version
        when :gt
          current_version > target_version
        when :gte
          current_version >= target_version
        when :eq
          current_version == target_version
        end
      end

      def gem_installed?(gem)
        INSTALLED_GEMS.key?(gem)
      end

      def valid_condition?(condition)
        %i[lt lte gt gte eq].flat_map { |x| [x, x.to_s] }.include?(condition)
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
