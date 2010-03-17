module RestScheduler
  class Scheduler
    def self.scheduler
      @scheduler ||= Rufus::Scheduler.start_new
    end

    def self.add(schedule_method, schedule_every, shell_command, postback_uri = nil)
      job = scheduler.send(schedule_method, schedule_every) do
        status, stdout, stderr = systemu(shell_command)
      end

      return job
    end
  end
end
