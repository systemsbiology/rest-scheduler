require File.dirname(__FILE__) + '/../config/environment'

require 'spec'
require 'spec/autorun'
require 'spec/interop/test'
require 'rack/test'

def app
  RestScheduler::Server
end

set :environment, :test

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
end
