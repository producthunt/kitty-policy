# frozen_string_literal: true

module KittyPolicy
  extend self

  module Helper
    extend self

    def rule_name(ability, subject = nil)
      if subject
        "can_#{ability}?"
      else
        "can_#{underscore(subject_to_string(subject)).tr('/', '_')}?"
      end
    end

    private

    def subject_to_string(subject)
      case subject
      when Class, Symbol then subject.to_s
      when String then subject.gsub(/[^\w]/, '')
      else subject.class.to_s
      end
    end

    def underscore(text)
      text.tr('::', '_')
          .gsub(/([A-Z]+)([A-Z][a-z])/) { "#{Regexp.last_match[1]}_#{Regexp.last_match[2]}" }
          .gsub(/([a-z\d])([A-Z])/) { "#{Regexp.last_match[1]}_#{Regexp.last_match[2]}" }
          .tr('-', '_')
          .downcase
    end
  end
end
