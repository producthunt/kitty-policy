# frozen_string_literal: true

module KittyPolicy
  module RSpec
    class ToBeAbleTo
      def initialize(policy, ability, subject)
        @policy = policy
        @ability = ability
        @subject = subject
      end

      def matches?(user)
        @policy.can?(user, @ability, @subject)
      end

      def failure_message
        "Expected user to be able to #{@ability.inspect} #{@subject.inspect unless @subject == :empty}, but isn't"
      end

      def failure_message_when_negated
        "Expected user not to be able to #{@ability.inspect} #{@subject.inspect unless @subject == :empty}, but is"
      end
    end

    def be_able_to(ability, subject = :empty)
      ToBeAbleTo.new(described_class, ability, subject)
    end
  end
end
