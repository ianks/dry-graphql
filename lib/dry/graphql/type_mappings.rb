# frozen_string_literal: true

require 'graphql/types'
require 'dry/core/class_attributes'

module Dry
  module GraphQL
    # Class to Ruby types to GraphQL types
    class TypeMappings
      class UnmappableTypeError < StandardError; end

      extend Dry::Core::ClassAttributes

      defines :scalar_mappings
      scalar_mappings(
        ::String => ::GraphQL::Types::String,
        ::Integer => ::GraphQL::Types::Int,
        ::TrueClass => ::GraphQL::Types::Boolean,
        ::FalseClass => ::GraphQL::Types::Boolean,
        ::Float => ::GraphQL::Types::Float,
        ::Date => ::GraphQL::Types::ISO8601DateTime,
        ::DateTime => ::GraphQL::Types::ISO8601DateTime,
        ::Time => ::GraphQL::Types::ISO8601DateTime
      )

      defines :registry
      registry(scalar_mappings)

      class << self
        def map_type(type, mappings = registry)
          mappings.fetch(type) do
            raise UnmappableTypeError,
                  "Cannot map #{type}. Please make sure " \
                  "it is registered by calling:\n" \
                  "Dry::GraphQL.register_type_mapping #{type}, MyGraphQLType"
          end
        end

        def map_scalar(type)
          map_type(type, scalar_mappings)
        end

        def scalar?(type)
          keys = scalar_mappings.keys
          keys.include?(type)
        end
      end
    end
  end
end
