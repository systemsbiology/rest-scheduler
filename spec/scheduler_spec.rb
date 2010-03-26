require File.dirname(__FILE__) + '/spec_helper.rb'

describe RestScheduler::Scheduler do
  before(:each) do
    @rufus_scheduler = mock("Rufus scheduler")

    # reload class to clear cached Rufus::Scheduler
    Object.send(:remove_const, 'RestScheduler')
    load File.dirname(__FILE__) + '/../lib/rest-scheduler/scheduler.rb'
    load File.dirname(__FILE__) + '/../lib/rest-scheduler/server.rb'
    load File.dirname(__FILE__) + '/../lib/rest-scheduler/task.rb'
  end

  it "should create a new scheduler if one doesn't exist, and provide it on subsequent calls" do
    Rufus::Scheduler.should_receive(:start_new).once.and_return(@rufus_scheduler)
    RestScheduler::Scheduler.scheduler.should == @rufus_scheduler
  end

  it "should provide an existing scheduler if it exists" do
    rufus_scheduler = mock("Rufus scheduler")
    Rufus::Scheduler.should_receive(:start_new).once.and_return(@rufus_scheduler)

    # first call should start a new scheduler
    RestScheduler::Scheduler.scheduler.should == @rufus_scheduler

    # second call should use existing scheduler
    RestScheduler::Scheduler.scheduler.should == @rufus_scheduler
  end

  describe "adding a job" do
    it "should successfully run the job without a postback uri" do
      job = RestScheduler::Scheduler.add("important job", "every", "500", "touch touched_test_file.txt")
      sleep 1
      job.unschedule
      File.should exist("touched_test_file.txt")
      FileUtils.rm "touched_test_file.txt"
    end

    describe "with a postback uri" do
      it "should successfully post the result to the postback uri" do
        expected_xml = "<task><name>important job</name>" +
                "<status>0</status>" +
                "<stdout></stdout>" +
                "<stderr></stderr></task>"
        RestClient.should_receive(:post).with("http://localhost:3000", expected_xml,
           :content_type => "application/xml").at_least(:once)
        job = RestScheduler::Scheduler.add("important job", "every", "100", "touch touched_test_file.txt",
          "http://localhost:3000")
        sleep 1
        job.unschedule
        File.should exist("touched_test_file.txt")
        FileUtils.rm "touched_test_file.txt"
      end

      it "should write an error to stdout if the postback server couldn't be reached" do
        expected_xml = "<task><name>important job</name>" +
                "<status>0</status>" +
                "<stdout></stdout>" +
                "<stderr></stderr></task>"
        RestClient.should_receive(:post).with("http://localhost:3000", expected_xml,
           :content_type => "application/xml").at_least(:once).and_raise(Errno::ECONNREFUSED)
        Kernel.should_receive(:puts).with("Couldn't post to http://localhost:3000").at_least(:once)
        puts "postback error spec"
        job = RestScheduler::Scheduler.add("important job", "every", "100", "touch touched_test_file.txt",
          "http://localhost:3000")
        sleep 1
        job.unschedule
        File.should exist("touched_test_file.txt")
        FileUtils.rm "touched_test_file.txt"
      end
    end
  end
end
