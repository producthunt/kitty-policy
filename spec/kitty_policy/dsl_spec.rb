# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KittyPolicy::DSL do
  def define_policy(&block)
    dsl = described_class
    Module.new do
      extend dsl

      instance_eval(&block)
    end
  end

  describe '.can?' do
    it 'can call can_[action]?' do
      policy = define_policy do
        can :edit do |user|
          user == :user
        end
      end

      expect(policy.can?(:user, :edit)).to eq true
      expect(policy.can?(:other, :edit)).to eq false

      expect(policy.can_edit?(:user)).to eq true
      expect(policy.can_edit?(:other)).to eq false
    end

    it 'can call can_[action]_[subject]?' do
      policy = define_policy do
        can :edit, :post do |user, post|
          user == :user && post.name == 'name'
        end
      end

      expect(policy.can?(:user, :edit, Post.new(name: 'name'))).to eq true
      expect(policy.can?(:user, :edit, Post.new)).to eq false
      expect(policy.can?(:other, :edit, Post.new(name: 'name'))).to eq false

      expect(policy.can_edit_post?(:user, Post.new(name: 'name'))).to eq true
      expect(policy.can_edit_post?(:user, Post.new)).to eq false
    end

    it 'can call can_[action]_[subject_class]?' do
      policy = define_policy do
        can :create, Post do |user|
          user == :user
        end
      end

      expect(policy.can?(:user, :create, Post)).to eq true
      expect(policy.can?(:other, :create, Post)).to eq false
      expect(policy.can?(nil, :create, Post)).to eq false

      expect(policy.can_create_post?(:user)).to eq true
      expect(policy.can_create_post?(:other)).to eq false
    end

    it 'can call can_[action]_[subject as string]?' do
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

  describe '.authorize!' do
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
    it 'accepts only action' do
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

    it 'has default block' do
      policy = define_policy do
        can :view
        can :create, :post
      end

      expect(policy.can?(:user, :view)).to eq true
      expect(policy.can?(:user, :create, :post)).to eq true
      expect(policy.can?(nil, :view)).to eq false
      expect(policy.can?(nil, :create, :post)).to eq false
    end

    it 'defines a method corresponding to ability' do
      policy = define_policy do
        can :view
        can :create, :post
        can :test, String
      end

      expect(policy).to respond_to :can_view?
      expect(policy).to respond_to :can_create_post?
      expect(policy).to respond_to :can_test_string?
    end

    it 'raises when can method already exists' do
      expect do
        define_policy do
          define_method(:can_edit_post?) { false }

          can :edit, :post
        end
      end.to raise_error 'Method "can_edit_post?" already exists'
    end
  end

  describe '.delegate_ability' do
    it 'delegates ability from object to other object' do
      policy = define_policy do
        can :edit, Post do |user, post|
          user == post.user
        end

        delegate_ability :edit, PostMedia, to: :post
      end

      post = Post.new(user: :user1)
      media = PostMedia.new(post: post)

      expect(policy).to respond_to :can_edit_post_media?

      expect(policy.can?(:user1, :edit, post)).to eq true
      expect(policy.can?(:user1, :edit, media)).to eq true

      expect(policy.can?(:user2, :edit, post)).to eq false
      expect(policy.can?(:user2, :edit, media)).to eq false
    end

    it 'can specify to which ability to delegate' do
      policy = define_policy do
        can :edit, Post do |user, post|
          user == post.user
        end

        delegate_ability :destroy, PostMedia, to: :post, to_ability: :edit
      end

      post = Post.new(user: :user1)
      media = PostMedia.new(post: post)

      expect(policy).to respond_to :can_destroy_post_media?

      expect(policy.can?(:user1, :edit, post)).to eq true
      expect(policy.can?(:user1, :destroy, media)).to eq true

      expect(policy.can?(:user2, :edit, post)).to eq false
      expect(policy.can?(:user2, :destroy, media)).to eq false
    end
  end
end
