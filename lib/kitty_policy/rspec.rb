# frozen_string_literal: true

module KittyPolicy
  module RSpec
    class ToBeAbleTo
      def initialize(policy, action, subject)
        @policy = policy
        @action = action
        @subject = subject
      end

      def matches?(user)
        @policy.can?(user, @action, @subject)
      end

      def failure_message
        "Expected user to be able to #{@action.inspect} #{@subject.inspect unless @subject == :empty}, but isn't"
      end

      def failure_message_when_negated
        "Expected user not to be able to #{@action.inspect} #{@subject.inspect unless @subject == :empty}, but is"
      end
    end

    def be_able_to(action, subject = :empty)
      ToBeAbleTo.new(described_class, action, subject)
    end
  end
end
