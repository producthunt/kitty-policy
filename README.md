# KittyPolicy

**NOT RELEASED YET**

Minimalistic authorization library extracted from [Product Hunt](https://www.producthunt.com/).

Features:

* small DSL for defining abilities
* not class initializations when performing abilities check
* integrations with [GraphQL gem](https://rubygems.org/gems/graphql).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kitty_policy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitty_policy

## Usage

### Step 1 - Define policy object

```ruby
module ApplicationPolicy
  extend KittyPolicy
  extend self

  # generates a method named `can_moderate?`
  # example: no subject, just action
  can :moderate do |user|
    user.admin?
  end

  # generates a method named `can_start_trial?`
  # example: `allow_guest` access
  can :start_trial, allow_guest: true do |user, _subscription|
    !user || user.trial_used?
  end

  # generates a method named `can_create_chat_room?`
  # example: subject as symbol
  can :create, :chat_room do |user|
    user.admin?
  end

  # generates a method named `can_create_post?`
  # example: subject as class, instance not used
  can :create, Post do |user|
    user.can_post?
  end

  # generates a method named `can_edit_post?`
  # example: subject as class, passing subject instance
  can :edit, Post do |user, post|
    user.admin?  || user == post.author
  end

  # generates a method named `can_manage_account?`
  # example: using a private helper method
  can :manage, Account do |user, account|
    user.admin? || member?(user, account)
  end

  private

  # you can extract private helper methods
  def member?(user, account)
    # ...
  end
end
```

`can` is just a convince helper to create methods on a module:

```
ApplicationPolicy.can_moderate?
ApplicationPolicy.can_start_trial?
ApplicationPolicy.can_create_post?
ApplicationPolicy.can_edit_post?
ApplicationPolicy.can_manage_account?
```

### Step 2 - Use policy object

```ruby
# answers if action is allowed to a user
ApplicationPolicy.can?(user, :create, Post)
ApplicationPolicy.can?(user, :create, Post.new)
ApplicationPolicy.can?(user, :create, post)
ApplicationPolicy.can?(user, :start_trial)

# raises `KittyPolicy::AccessDenied` when action isn't allowed to user
ApplicationPolicy.authorize!(user, :create, Post)
ApplicationPolicy.authorize!(user, :create, Post.new)
ApplicationPolicy.authorize!(user, :create, post)
ApplicationPolicy.authorize!(user, :start_trial)
```

### (Optional Step) - Group policies into separate files

You can split your logic into multiple policy files:

```ruby
module Posts::Policy
  extend KittyPolicy
  extend self

  # ... define abilities
end
```

Then you can group them together.

```ruby
module ApplicationPolicy
  extend Posts::Policy
  extend Ship::Policy
end
```

### Testing with RSpec

```ruby
require 'spec_helper'
require 'kitty_policy/rspec'

describe ApplicationPolicy do
  include KittyPolicy::RSpec

  describe 'can_moderate?' do
    it 'returns true for admin' do
      expect(User.new(admin: true)).to be_able_to :moderate
    end

    it 'returns false for everyone else' do
      expect(User.new(admin: false)).not_to be_able_to :moderate
    end
  end
end
```

### Integration with GraphQL

#### Can Resolver

Exposes if current user can perform certain action.

```ruby
# Manually import graphql plugin
require 'kitty_policy/graphql/can_resolver'

module Resolvers
  Can = KittyPolicy::GraphQL::CanResolver.new(
    policy: ApplicationPolicy,        # required
    base_resolver: BaseResolver,      # optional, default: ::GraphQL::Schema::Resolver,
    current_user_key: :current_user,  # optional, default: :current_user
  )
end
```

```ruby
module Types
  class PostType < BaseObject
    # ...

    field :can_edit, resolver: Resolvers::Can.perform(:edit)                   # -> ApplicationPolicy.can?(edit, post)
    field :can_moderate, resolver: Resolvers::Can.perform(:moderate) { :site } # -> ApplicationPolicy.can?(:moderate, :site)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Run the tests (`rake`)
6. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the KittyPolicy project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/producthunt/kitty-policy/blob/master/CODE_OF_CONDUCT.md).
