module Dry
  module GraphQL
    # Adds graphql_type to a rom relation
    #
    # @example
    #
    # require 'dry/graphql/rom'
    #
    # class Users < ROM::Relation[:sql]
    #   extend Dry::GraphQL::ROM
    # end
    module ROM
      def self.graphql_type
        return @graphql_type if @graphql_type

        base_schema = schema.any?(&:read?) ? schema.to_output_hash : NOOP_OUTPUT_SCHEMA
        @graphql_type ||= Dry::GraphQL.from(base_schema, name: 'Store')
      end
    end
  end
end
