require File.dirname(__FILE__) + '/spec_helper.rb'

describe RestScheduler::Task do
  before(:each) do
    RestScheduler::Task.destroy_all
  end

  describe "saving a task" do
    it "should work if the task if valid and starts" do
      task = RestScheduler::Task.new(
        :name => "Do stuff",
        :schedule_method => "every",
        :schedule_every => "5s",
        :shell_command => "touch some_file.txt"
      )
      task.should_receive(:start).and_return(true)
      task.save.should be_true
    end

    it "should not work if the task is invalid" do
      task = RestScheduler::Task.new(
        :name => "Do stuff",
        :schedule_method => "occasionally",
        :schedule_every => "5s",
        :shell_command => "touch some_file.txt"
      )
      task.should_not_receive(:start)
      task.save.should_not be_true
    end

    it "should not work if the task doesn't start" do
      task = RestScheduler::Task.new(
        :name => "Do stuff",
        :schedule_method => "at",
        :schedule_every => "5s",
        :shell_command => "touch some_file.txt"
      )
      task.should_receive(:start).and_return(false)
      task.save.should_not be_true
    end
  end

  it "should stop a task when it gets destroyed" do
    task = RestScheduler::Task.create(
      :name => "Do stuff",
      :schedule_method => "at",
      :schedule_every => "5s",
      :shell_command => "touch some_file.txt"
    )
    task.should_receive(:stop)
    task.destroy
  end 

  describe "starting a task" do
    before(:each) do
      @task = RestScheduler::Task.create(
        :name => "Do stuff",
        :schedule_method => "every",
        :schedule_every => "5s",
        :shell_command => "touch some_file.txt",
        :postback_uri => "http://localhost:5678"
      )
    end

    it "should schedule the task and return it if no there are no errors" do
      job = mock("Job")
      RestScheduler::Scheduler.should_receive(:add).with(
        @task.name, @task.schedule_method.to_sym, @task.schedule_every,
        @task.shell_command, @task.postback_uri
      ).and_return(job)
      job.should_receive(:job_id).and_return(23)
      @task.start
    end

    it "should return false if there is an argument error" do
      job = mock("Job")
      RestScheduler::Scheduler.should_receive(:add).with(
        @task.name, @task.schedule_method.to_sym, @task.schedule_every,
        @task.shell_command, @task.postback_uri
      ).and_raise(ArgumentError)
      @task.start.should be_false
      @task.errors.size.should == 1
    end

    it "should return false if there is a runtime error" do
      job = mock("Job")
      RestScheduler::Scheduler.should_receive(:add).with(
        @task.name, @task.schedule_method.to_sym, @task.schedule_every,
        @task.shell_command, @task.postback_uri
      ).and_raise(RuntimeError)
      @task.start.should be_false
      @task.errors.size.should == 1
    end
  end

  it "should stop a task" do
    task = RestScheduler::Task.create(
      :name => "Do stuff",
      :schedule_method => "every",
      :schedule_every => "5s",
      :shell_command => "touch some_file.txt"
    )
    scheduler = mock("Scheduler")
    RestScheduler::Scheduler.should_receive(:scheduler).and_return(scheduler)

    scheduler.should_receive(:unschedule).with(task.job_id)
    task.stop
  end 

  it "should start all tasks" do
    task_1 = RestScheduler::Task.create(
      :name => "Do stuff",
      :schedule_method => "every",
      :schedule_every => "5s",
      :shell_command => "touch some_file.txt",
      :job_id => 23
    )
    task_2 = RestScheduler::Task.create(
      :name => "Do more stuff",
      :schedule_method => "every",
      :schedule_every => "5s",
      :shell_command => "touch some_file.txt",
      :job_id => 24
    )

    RestScheduler::Task.should_receive(:all).and_return( [task_1,task_2] )
    task_1.should_receive(:save)
    task_2.should_receive(:save)

    RestScheduler::Task.start_all
  end

  it "should stop all tasks" do
    task_1 = RestScheduler::Task.create(
      :name => "Do stuff",
      :schedule_method => "every",
      :schedule_every => "5s",
      :shell_command => "touch some_file.txt",
      :job_id => 23
    )
    task_2 = RestScheduler::Task.create(
      :name => "Do more stuff",
      :schedule_method => "every",
      :schedule_every => "5s",
      :shell_command => "touch some_file.txt",
      :job_id => 24
    )

    RestScheduler::Task.should_receive(:all).and_return( [task_1,task_2] )
    task_1.should_receive(:stop)
    task_2.should_receive(:stop)

    RestScheduler::Task.stop_all
  end
end
