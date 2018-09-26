module Dry
  module GraphQL
    module Types
      # JSON type, needed for Dry::Types::Hash currently
      class JSON < ::GraphQL::Schema::Scalar
        description 'A valid JSON document, transported as a string'

        def self.coerce_input(str, _ctx)
          JSON.parse(str)
        end

        def self.coerce_result(obj, _ctx)
          JSON.dump(obj)
        end
      end
    end
  end
end
