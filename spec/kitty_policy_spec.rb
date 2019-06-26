# frozen_string_literal: true

require 'spec_helper'

class Post
  attr_reader :name, :user

  def initialize(name: nil, user: nil)
    @name = name
    @user = user
  end
end

RSpec.describe KittyPolicy do
  def define_policy(&block)
    policy_module = described_class
    Module.new do
      extend policy_module
      extend self

      instance_eval(&block)
    end
  end

  describe '.can?' do
    it 'can call can_[ability]?' do
      policy = define_policy do
        can :edit do |user|
          user == :user
        end
      end

      expect(policy.can?(:user, :edit)).to eq true
      expect(policy.can?(:other, :edit)).to eq false
    end

    it 'can call can_[ability]_[subject]?' do
      policy = define_policy do
        can :edit, :post do |user, post|
          user == :user && post.name == 'name'
        end
      end

      expect(policy.can?(:user, :edit, Post.new(name: 'name'))).to eq true
      expect(policy.can?(:user, :edit, Post.new)).to eq false
      expect(policy.can?(:other, :edit, Post.new(name: 'name'))).to eq false
    end

    it 'can call can_[ability]_[subject_class]?' do
      policy = define_policy do
        can :create, Post do |user|
          user == :user
        end
      end

      expect(policy.can?(:user, :create, Post)).to eq true
      expect(policy.can?(:other, :create, Post)).to eq false
      expect(policy.can?(nil, :create, Post)).to eq false
    end

    it 'can call can_[ability]_[subject as string]?' do
      policy = define_policy do
        can :create, Post do |user|
          user == :user
        end
      end

      expect(policy.can?(:user, :create, 'Post')).to eq true
      expect(policy.can?(:user, :create, '(Post);?!')).to eq true
      expect(policy.can?(:other, :create, 'Post')).to eq false
    end
  end

  describe 'authorize!' do
    it 'raises when can? returns false' do
      policy = define_policy do
        can :edit do
          false
        end
      end

      expect { policy.authorize! :user, :edit }.to raise_error KittyPolicy::AccessDenied
    end

    it 'doesnt raises when can? returns true' do
      policy = define_policy do
        can :edit do
          true
        end
      end

      expect { policy.authorize! :user, :edit }.not_to raise_error
    end
  end

  describe '.can' do
    it 'accepts only ability' do
      policy = define_policy do
        can :moderate do
          true
        end
      end

      expect(policy.can?(:user, :moderate)).to eq true
    end

    it 'accepts multiple abilities' do
      policy = define_policy do
        can %i(do_one do_two), :thing do
          true
        end
      end

      expect(policy.can?(:user, :do_one, :thing)).to eq true
      expect(policy.can?(:user, :do_two, :thing)).to eq true
    end

    it 'accepts symbol for subject' do
      policy = define_policy do
        can :edit, :subject do
          true
        end
      end

      expect(policy.can?(:user, :edit, :subject)).to eq true
    end

    it 'accepts string for subject' do
      policy = define_policy do
        can :edit, 'subject' do
          true
        end
      end

      expect(policy.can?(:user, :edit, 'subject')).to eq true
    end

    it 'accepts class for subject' do
      policy = define_policy do
        can :edit, String do
          true
        end
      end

      expect(policy.can?(:user, :edit, String)).to eq true
    end

    it 'passes user as argument' do
      policy = define_policy do
        can :be_tested do |user|
          user == :user
        end
      end

      expect(policy.can?(:user, :be_tested)).to eq true
      expect(policy.can?(:other, :be_tested)).to eq false
    end

    it 'passes subject as argument' do
      policy = define_policy do
        can :edit, :subject do |_user, subject|
          subject == :subject
        end
      end

      expect(policy.can?(:user, :edit, :subject)).to eq true
    end

    it 'requires an user' do
      policy = define_policy do
        can :vote do
          true
        end
      end

      expect(policy.can?(:user, :vote)).to eq true
      expect(policy.can?(nil, :vote)).to eq false
    end

    it 'can allow guest users' do
      policy = define_policy do
        can :register, allow_guest: true, &:!
      end

      expect(policy.can?(:user, :register)).to eq false
      expect(policy.can?(nil, :register)).to eq true
    end
  end
end
