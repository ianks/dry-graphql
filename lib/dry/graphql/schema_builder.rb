require 'graphql'
require 'dry/graphql/type_mappings'

module Dry
  module GraphQL
    # Reduces a DRY type to a GraphQL type
    class SchemaBuilder
      attr_reader :field, :type, :options, :schema, :name, :parent

      class TypeMappingError < StandardError; end

      def initialize(name: nil, type: nil, schema: nil, parent: nil, options: {})
        @name = name
        @type = type
        @schema = schema
        @options = options
        @parent = parent
      end

      def with(opts)
        self.class.new({
          name: @name, type: @type, schema: @schema, options: @options,
          parent: self
        }.merge(opts))
      end

      def reduce_with(*args)
        with(*args).reduce
      end

      def graphql_type
        reduce
      end

      protected

      def reduce
        case type
        when specified_in_meta?
          type.meta[:graphql_type]
        when mappable?
          TypeMappings.map_type type
        when primitive?
          reduce_with type: type.primitive
        when input?
          map_input type
        when Dry::Types::Hash::Schema
          map_hash type
        when Dry::Types::Constrained, Dry::Types::Constructor
          reduce_with type: type.type
        when Dry::Types::Sum::Constrained
          reduce_with type: type.right
        else
          raise TypeMappingError, "Cannot map #{type} to GraphQL type"
        end
      end

      def primitive?
        lambda do |type|
          type.respond_to?(:primitive) && TypeMappings.mappable?(type.primitive)
        end
      end

      def mappable?
        TypeMappings.method(:mappable?)
      end

      def input?
        ->(type) { type.respond_to?(:input) }
      end

      def specified_in_meta?
        ->(type) { type.respond_to?(:meta) && type.meta.key?(:graphql_type) }
      end

      def map_hash(type)
        type.options[:member_types].each do |field_name, field_type|
          schema.field(
            field_name,
            with(name: field_name, type: field_type).reduce,
            null: nullable?(field_type)
          )
        end
        schema
      end

      def map_input(type)
        graphql_schema = Class.new(::GraphQL::Schema::Object)
        graphql_schema.graphql_name(type.name.to_s.gsub('::', '__'))
        opts = { name: type.name, type: type.input, schema: graphql_schema }
        SchemaBuilder.new(opts).reduce
      end

      def nullable?(type)
        return false unless type.respond_to?(:left)

        type.left.type.primitive == NilClass
      end
    end
  end
end
