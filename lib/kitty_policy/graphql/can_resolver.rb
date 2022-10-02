# frozen_string_literal: true

module KittyPolicy
  module GraphQL
    class CanResolver
      def initialize(policy:, base_resolver: ::GraphQL::Schema::Resolver, current_user_key: :current_user)
        @base_resolver = base_resolver
        @current_user_key = current_user_key
        @policy = policy
      end

      def perform(action, &extract_subject)
        policy = @policy
        current_user_key = @current_user_key

        Class.new(@base_resolver) do
          type ::GraphQL::Types::Boolean, null: false

          define_method(:resolve) do
            policy.can?(
              context[current_user_key],
              action,
              extract_subject ? extract_subject.call(object) : object,
            )
          end
        end
      end

      def field_options
        raise "Can't use `#{self.class.name}` directly as resolver. Use `resolve: #{self.class.name}.perform(action)`"
      end
    end
  end
end
