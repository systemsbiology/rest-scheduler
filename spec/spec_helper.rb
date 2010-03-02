require File.dirname(__FILE__) + '/../config/environment'

require 'spec'
#require 'spec/autorun'
require 'spec/interop/test'
require 'rack/test'

Test::Unit::TestCase.send :include, Rack::Test::Methods

set :environment, :test

def app
  RestScheduler::Server
end

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end
