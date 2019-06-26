# frozen_string_literal: true

module KittyPolicy
  class AccessDenied < StandardError
    attr_reader :user, :ability, :subject

    def initialize(user = nil, ability = nil, subject = nil)
      @user = user
      @ability = ability
      @subject = subject

      super 'Not authorized'
    end
  end
end
