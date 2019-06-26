# frozen_string_literal: true

require 'spec_helper'
require 'graphql'
require 'kitty_policy/graphql/can_resolver'

RSpec.describe KittyPolicy::GraphQL::CanResolver do # rubocop:disable RSpec/FilePath
  let(:resolver_factory) { described_class.new(policy: ExamplePolicy, base_resolver: ::GraphQL::Schema::Resolver, current_user_key: :user) }

  it 'raises when the resolver factory is accessed directly' do
    expect { resolver_factory.field_options }.to raise_error(/Can't use.*directly as resolver/)
  end

  describe '#perform' do
    it 'creates a resolver attached to action' do
      resolver = resolver_factory.perform(:edit)

      post = Post.new(user: :user)

      expect_result(resolver, object: post, context: { user: post.user }).to eq true
      expect_result(resolver, object: post, context: { user: :other }).to eq false
    end

    it 'can have custom subject for the policy' do
      resolver = resolver_factory.perform(:moderate) { nil }

      expect_result(resolver, context: { user: :admin }).to eq true
      expect_result(resolver, context: { user: :other }).to eq false
    end
  end

  def expect_result(resolver_class, object: nil, context: {}, **inputs)
    resolver = resolver_class.new(
      object: object,
      context: ::GraphQL::Query::Context.new(
        query: OpenStruct.new(schema: nil),
        values: context,
        object: object,
      ),
    )

    result = inputs.empty? ? resolver.resolve : resolver.resolve(inputs)
    expect(result) # rubocop:disable RSpec/VoidExpect
  end
end
