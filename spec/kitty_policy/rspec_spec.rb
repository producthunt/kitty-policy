# frozen_string_literal: true

require 'spec_helper'
require 'kitty_policy/rspec'

module ExamplePolicy
  extend KittyPolicy::DSL

  can :moderate do |user|
    user == :user
  end
end

RSpec.describe ExamplePolicy do
  include KittyPolicy::RSpec

  describe '.be_able_to' do
    it 'returns true when user is able to action' do
      expect(:user).to be_able_to :moderate # rubocop:disable RSpec/ExpectActual
    end

    it 'returns false when user isnt able to action' do
      expect(:other).not_to be_able_to :moderate # rubocop:disable RSpec/ExpectActual
    end
  end
end
