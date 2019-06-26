# frozen_string_literal: true

require 'kitty_policy/version'
require 'kitty_policy/access_denied'
require 'kitty_policy/helper'

module KittyPolicy
  def can?(user, action, subject = :empty)
    if subject == :empty
      public_send Helper.method_name(action), user
    else
      public_send Helper.method_name(action, subject), user, subject
    end
  end

  def authorize!(*args)
    raise AccessDenied.new(*args) unless can?(*args)
  end

  private

  def can(abilities, subject = nil, allow_guest: false, &block)
    Array(abilities).each do |action|
      define_method Helper.method_name(action, subject) do |*args|
        (args[0] || allow_guest) && !!block.call(*args)
      end
    end
  end
end
