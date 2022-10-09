# frozen_string_literal: true

require 'spec_helper'
require 'kitty_policy/rspec'

RSpec.describe KittyPolicy::Helper do
  describe '.method_name' do
    it 'returns can_[action]? when only action is passed' do
      expect(described_class.method_name(:action)).to eq 'can_action?'
      expect(described_class.method_name('action')).to eq 'can_action?'
    end

    it 'returns can_[action]_[subject]? when action and subject is passed' do
      expect(described_class.method_name(:edit, :post)).to eq 'can_edit_post?'
    end

    it 'handles subject as string' do
      expect(described_class.method_name(:edit, 'post')).to eq 'can_edit_post?'
    end

    it 'handles subject as class' do
      expect(described_class.method_name(:edit, Post)).to eq 'can_edit_post?'
    end

    it 'underscores subject' do
      expect(described_class.method_name(:edit, 'PostMedia')).to eq 'can_edit_post_media?'
    end

    it 'handles modules' do
      expect(described_class.method_name(:use, 'SignIn::Token')).to eq 'can_use_sign_in_token?'
      expect(described_class.method_name(:use, 'SignIn/Token')).to eq 'can_use_sign_in_token?'
    end
  end
end
