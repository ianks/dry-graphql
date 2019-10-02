# frozen_string_literal: true

require 'dry/graphql/version'
require 'dry-struct'
require 'dry/graphql/schema_builder'

module Dry
  # Module containing GraphQL enhancements
  module GraphQL
    # Extends Dry::Struct functionality
    module Struct
      def graphql_type(options = {})
        return @graphql_type if @graphql_type

        graphql_name = name.to_s.gsub('::', '__')
        graphql_schema = SchemaBuilder.build_graphql_schema_class(name)
        graphql_schema.graphql_name(name)
        schema_hash = schema.each_with_object({}) do |type, memo|
          memo[type.name] = type.type
        end

        opts = { name: graphql_name, type: schema_hash, schema: graphql_schema, options: options }
        @graphql_type ||= SchemaBuilder.new(opts).graphql_type
      end
    end

    class << self
      def from(type, name:, schema:, **opts)
        SchemaBuilder.new(name: name, type: type, schema: schema, options: opts).graphql_type
      end

      def register_type_mapping(input_type, output_type)
        TypeMappings.registry.merge!(input_type => output_type)
      end
    end
  end
end

Dry::Struct.extend(Dry::GraphQL::Struct)
