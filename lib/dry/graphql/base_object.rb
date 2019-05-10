# frozen_string_literal: true

module Dry
  module GraphQL
    # Base schema object
    class BaseObject < ::GraphQL::Schema::Object
      def self.map_from(*associated_classes)
        associated_classes.each do |associated_class|
          ::Dry::GraphQL.register_type_mapping(associated_class, self)
        end
        true
      end
    end
  end
end
