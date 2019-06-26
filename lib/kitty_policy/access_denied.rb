# frozen_string_literal: true

module KittyPolicy
  class AccessDenied < StandardError
    attr_reader :user, :action, :subject

    def initialize(user = nil, action = nil, subject = nil)
      @user = user
      @action = action
      @subject = subject

      super 'Not authorized'
    end
  end
end
