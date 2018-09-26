# Dry::GraphQL

`dry-graphql` makes [dry-types](https://dry-rb.org/gems/dry-types/) and
[dry-struct](https://dry-rb.org/gems/dry-types/) play nicely with GraphQL. It
adds a `graphql_type` method which will automatically generate a
[graphql-ruby](http://graphql-ruby.org/). This takes the manual work out of
maintaining schema types.

## Usage

Here is an example of using it with `dry-struct`:

```ruby
class User < Dry::Struct
  module Types
    include Dry::Types.module
  end

  attribute :name, Types::Strict::String.optional
  attribute :age, Types::Coercible::Integer
end

class Query < GraphQL::Schema::Object
  field :user, User.graphql_type, null: false
end

class Schema < GraphQL::Schema
  query Query
end

puts schema.to_definition # =>
# type Query {
#   user: User!
# }
#
# type User {
#   age: Int!
#   name: String
# }
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-graphql'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dry-graphql


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/adhawk/dry-graphql. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dry::GraphQL project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/adhawk/dry-graphql/blob/master/CODE_OF_CONDUCT.md).
