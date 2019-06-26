# frozen_string_literal: true

require 'spec_helper'
require 'kitty_policy/rspec'

RSpec.describe ExamplePolicy do # rubocop:disable RSpec/FilePath
  include KittyPolicy::RSpec

  describe '.be_able_to' do
    it 'returns true when user is able to action' do
      expect(:admin).to be_able_to :moderate # rubocop:disable RSpec/ExpectActual
    end

    it 'returns false when user isnt able to action' do
      expect(:other).not_to be_able_to :moderate # rubocop:disable RSpec/ExpectActual
    end
  end
end
