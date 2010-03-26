require File.dirname(__FILE__) + '/spec_helper.rb'

describe RestScheduler::Server do
  def mock_task
    @mock_task ||= mock(
      "Task",
      :id => 23,
      :name => "Do stuff",
      :schedule_method => "every",
      :schedule_every => "5s",
      :shell_command => "touch some_file.txt"
    )                        
  end

  it "should respond to GET /tasks with success" do
    @tasks = [mock_task]
    RestScheduler::Task.should_receive(:all).and_return(@tasks)
    get '/tasks'
    last_response.should be_ok
  end

  describe "responding to GET /tasks/:id" do
    it "should respond with success if the task is found" do
      RestScheduler::Task.should_receive(:find).with("23").and_return(mock_task)
      get '/tasks/23'
      last_response.should be_ok
    end

    it "should respond with a 404 stsatus if the task was not found" do
      RestScheduler::Task.should_receive(:find).with("23").and_raise(ActiveRecord::RecordNotFound)
      get '/tasks/23'
      last_response.status.should == 404
    end
  end

  describe "responding to POST /tasks" do
    describe "with valid XML formatting" do
      before(:each) do
        RestScheduler::Task.should_receive(:new).with(
          :name => "Do Stuff",
          :schedule_method => "every",
          :schedule_every => "5s",
          :shell_command => "touch some_file.txt",
          :postback_uri => nil
        ).and_return(mock_task)
      end

      it "should save the task if it is valid" do
        mock_task.should_receive(:save).and_return(true)
        post '/tasks', '<task><name>Do Stuff</name><schedule_method>every</schedule_method>' +
          '<schedule_every>5s</schedule_every><shell_command>touch some_file.txt</shell_command></task>'
        last_response.status.should == 201
        last_response.headers["Location"].should match("/tasks/23")
        last_response.headers["Content-Location"].should match("/tasks/23") 
      end

      it "should give a 422 status and error message if the task is not valid" do
        mock_task.should_receive(:save).and_return(false)
        mock_errors = mock("Errors", :to_xml => "Error XML")
        mock_task.should_receive(:errors).and_return( mock_errors )
        post '/tasks', '<task><name>Do Stuff</name><schedule_method>every</schedule_method>' +
          '<schedule_every>5s</schedule_every><shell_command>touch some_file.txt</shell_command></task>'
        last_response.status.should == 422
        last_response.body.should == "Error XML"
      end
    end

    it "should give a 422 status if the XML can't be parsed" do
      post '/tasks', '<task>asdfsadf'
      last_response.status.should == 422
      last_response.body.should match(/Error parsing XML/)
    end
  end

  describe "responding to DELETE /task/:id" do
    it "should delete the task if it exists" do
      RestScheduler::Task.should_receive(:find).with("23").and_return(mock_task)
      mock_task.should_receive(:destroy)
      delete '/tasks/23'
      last_response.should be_ok
    end

    it "should return a 404 status if the task doesn't exist" do
      RestScheduler::Task.should_receive(:find).with("23").and_raise(ActiveRecord::RecordNotFound)
      delete '/tasks/23'
      last_response.status.should == 404
    end
  end
end
