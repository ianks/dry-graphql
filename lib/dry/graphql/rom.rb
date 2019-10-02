# frozen_string_literal: true

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
      def graphql_type(opts = {})
        return @graphql_type if @graphql_type

        base_schema = schema.to_output_hash

        schema_hash = base_schema.each_with_object({}) do |type, memo|
          memo[type.name] = type.type
        end

        type_name = Dry::Core::Inflector.singularize(name)
        graphql_name = type_name.to_s.gsub('::', '__')
        graphql_schema = SchemaBuilder.build_graphql_schema_class(graphql_name)
        graphql_schema.graphql_name(graphql_name)

        @graphql_type ||= Dry::GraphQL.from(schema_hash, name: type_name, schema: graphql_schema, **opts)
      end
    end
  end
end
