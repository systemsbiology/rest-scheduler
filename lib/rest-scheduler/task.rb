require 'active_record'

dbconfig = YAML.load_file( File.join(APP_ROOT, "config", "database.yml") )
ActiveRecord::Base.establish_connection(
  :adapter => dbconfig['adapter'],
  :database => File.join( APP_ROOT, dbconfig['database'] )
)

module RestScheduler
  class Task < ActiveRecord::Base
    validates_presence_of :name, :schedule_method, :schedule_every, :shell_command
    validates_uniqueness_of :name
    validates_inclusion_of :schedule_method, :in => %w( in at cron every ),
      :message => "schedule method must be 'in', 'at', 'cron' or 'every'"

    def save
      return false unless valid?
      return false unless start

      super
    end

    def destroy
      stop
      super
    end

    def start
      puts "Trying to send scheduler method: #{schedule_method}, time: #{schedule_every}," +
           " command: #{shell_command}"
      begin
        job = Scheduler.scheduler.send(schedule_method.to_sym, schedule_every) do
          `#{shell_command}`
        end

        self.job_id = job.job_id
      rescue ArgumentError => e
        errors.add_to_base("#{e.message} for schedule method '#{schedule_method}'")
        return false
      rescue RuntimeError => e
        errors.add_to_base(e.message)
        return false
      end
    end

    def stop
      puts "Trying to unschedule #{job_id}"
      Scheduler.scheduler.unschedule(job_id)
    end

    def self.start_all
      all.each do |task|
        task.save
      end
    end

    def self.stop_all
      all.each do |task|
        task.stop
        task.update_attributes(:job_id => nil)
      end
    end
  end
end
