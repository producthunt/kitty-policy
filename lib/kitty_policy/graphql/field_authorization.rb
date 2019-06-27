# frozen_string_literal: true

if defined?(::GraphQL::Field)
  ::GraphQL::Field.accepts_definitions(
    fallback: GraphQL::Define.assign_metadata_key(:fallback),
    authorize: GraphQL::Define.assign_metadata_key(:authorize),
  )
end

if defined?(::GraphQL::Schema::Field)
  ::GraphQL::Schema::Field.accepts_definition(:fallback)
  ::GraphQL::Schema::Field.accepts_definition(:authorize)
end

module KittyPolicy
  module GraphQL
    class FieldAuthorization
      def initialize(policy:, current_user_key: :current_user)
        @policy = policy
        @current_user_key = current_user_key
      end

      def instrument(_type, field)
        return field unless field.metadata.key?(:authorize)

        policy = @policy
        current_user_key = @current_user_key

        old_resolve = field.resolve_proc
        new_resolve = lambda do |type_or_object, arguments, context|
          object = type_or_object.is_a?(::GraphQL::Schema::Object) ? type_or_object.object : type_or_object

          if policy.can?(context[current_user_key], field.metadata[:authorize], object)
            old_resolve.call(type_or_object, arguments, context)
          else
            field.metadata[:fallback]
          end
        end

        field.redefine do
          resolve new_resolve
        end
      end
    end
  end
end
