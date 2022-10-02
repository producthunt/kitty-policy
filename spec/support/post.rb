# frozen_string_literal: true

class Post
  attr_reader :name, :user

  def initialize(name: nil, user: nil)
    @name = name
    @user = user
  end
end

class PostMedia
  attr_reader :post

  def initialize(post: nil)
    @post = post
  end
end
