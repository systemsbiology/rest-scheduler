module RestScheduler
  class Scheduler
    def self.scheduler
      @scheduler ||= Rufus::Scheduler.start_new
    end
  end
end
