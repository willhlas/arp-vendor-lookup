require "simplecov"
SimpleCov.start "rails" do
  minimum_coverage 100

  # Unused Rails scaffold with no custom code (see CLAUDE.md: this app has no
  # background jobs or mailers). Excluded rather than relied on for coverage,
  # since they're only loaded when `config.eager_load` is on, making them
  # untracked and coverage-flaky outside of `CI=true` runs.
  skip "app/jobs/application_job.rb"
  skip "app/mailers/application_mailer.rb"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
