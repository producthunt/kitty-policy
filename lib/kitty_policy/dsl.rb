# frozen_string_literal: true

module KittyPolicy
  module DSL
    def self.extended(base)
      base.extend(base)
    end

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

    DEFAULT_BLOCK = ->(user, *_rest) { !!user }

    def can(abilities, subject = nil, allow_guest: false, &block)
      block ||= DEFAULT_BLOCK

      Array(abilities).each do |action|
        method_name = Helper.method_name(action, subject)

        raise %(Method "#{method_name}" already exists) if method_defined?(method_name)

        define_method method_name do |*args|
          (args[0] || allow_guest) && !!block.call(*args)
        end
      end
    end
  end
end
