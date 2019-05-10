# frozen_string_literal: true

require 'bundler/setup'
require 'dry/graphql'

module VersionHelpers
  def dry_struct_5?
    !Dry::Struct::VERSION.start_with?('0.5')
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.extend VersionHelpers
end
