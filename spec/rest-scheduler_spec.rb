require File.dirname(__FILE__) + '/spec_helper.rb'

describe "the server" do
  include Rack::Test::Methods

  it "should respond to GET /tasks" do
    @tasks = Array.new
    RestScheduler::Task.should_receive(:all).and_return(@tasks)
    get '/tasks'
    last_response.should be_ok
  end
end
