module RestScheduler
  class Runner
    def self.run
      # start existing tasks that would have stopped when the server was last stopped
      RestScheduler::Task.start_all

      # start the Sinatra app
      RestScheduler::Server.run! :port => '4567'
    end
  end
end
