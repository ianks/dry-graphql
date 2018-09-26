require 'dry-graphql'

RSpec.describe Dry::GraphQL do
  it 'has a version number' do
    expect(Dry::GraphQL::VERSION).not_to be nil
  end

  let(:user_struct) do
    unless defined?(User)
      class User < Dry::Struct
        module Types
          include Dry::Types.module
        end

        attribute :uuid, Types::Strict::String.meta(
          graphql_type: ::GraphQL::Types::ID
        )
        attribute :name, Types::Strict::String.optional
        attribute :age, Types::Coercible::Integer
        attribute :created_at, Types::Date
      end
    end

    User
  end

  it 'includes to correct field names' do
    graphql_field_names = user_struct.graphql_type.fields.keys

    expected = %w[name age createdAt uuid]

    expect(graphql_field_names).to match_array(expected)
  end

  it 'correctly determines nullability' do
    graphql_fields = user_struct.graphql_type.fields

    expect(nullable?(graphql_fields['name'])).to eq(true)
    expect(nullable?(graphql_fields['age'])).to eq(false)
  end

  it 'resolved to the type in meta[:graphql_type] if specified' do
    graphql_fields = user_struct.graphql_type.fields
    uuid_field = graphql_fields['uuid']

    expect(uuid_field.type.of_type).to eql(GraphQL::Types::ID)
  end

  it 'sets the graphql_name' do
    graphql_type = user_struct.graphql_type

    expect(graphql_type.graphql_name).to eq('User')
  end

  context 'with a nested schema' do
    let(:nested_user_struct) do
      unless defined?(NestedUser)
        class NestedUser < Dry::Struct
          module Types
            include Dry::Types.module
          end

          def self.name
            'User'
          end

          attribute :info do
            attribute :name, Types::Strict::String.optional
            attribute :age, Types::Coercible::Integer
          end
        end
      end

      NestedUser
    end

    it 'generates a correct schema' do
      type = nested_user_struct.graphql_type

      query = Class.new(GraphQL::Schema::Object) do
        graphql_name 'Query'
        field :user, type, null: false
      end

      schema = Class.new(GraphQL::Schema) do
        query query
      end

      expect(schema.to_definition).to eql <<-GQL.strip.gsub(/^[ \t]{8}/, '')
        type NestedUser__Info {
          age: Int!
          name: String
        }

        type Query {
          user: User!
        }

        type User {
          info: NestedUser__Info!
        }
      GQL
    end
  end

  def nullable?(field)
    field.instance_variable_get(:@return_type_null)
  end
end
