require 'dry/graphql/version'
require 'dry-struct'
require 'dry/graphql/schema_builder'

module Dry
  # Module containing GraphQL enhancements
  module GraphQL
    # Extends Dry::Struct functionality
    module Struct
      def graphql_type
        SchemaBuilder.new(name: name, type: self).graphql_type
      end
    end

    class << self
      def register_type(input_type, output_type)
        TypeMappings.registry.merge!(input_type => output_type)
      end
    end
  end
end

Dry::Struct.extend(Dry::GraphQL::Struct)
