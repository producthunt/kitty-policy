# frozen_string_literal: true

module KittyPolicy
  module Helper
    extend self

    def method_name(action, subject = nil)
      if subject
        "can_#{action}_#{underscore(subject_to_string(subject)).tr('/', '_')}?"
      else
        "can_#{action}?"
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
