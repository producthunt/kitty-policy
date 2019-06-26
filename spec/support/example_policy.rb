# frozen_string_literal: true

require_relative './post'

module ExamplePolicy
  extend KittyPolicy::DSL

  can :moderate do |user|
    user == :admin
  end

  can :edit, Post do |user, post|
    user == post.user
  end
end
