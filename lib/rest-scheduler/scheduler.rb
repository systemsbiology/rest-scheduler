module RestScheduler
  class Scheduler
    def self.scheduler
      @scheduler ||= Rufus::Scheduler.start_new
    end

    def self.add(name, schedule_method, schedule_every, shell_command, postback_uri = nil)
      puts "postback uri: #{postback_uri}"
      job = scheduler.send(schedule_method, schedule_every) do
        status, stdout, stderr = systemu(shell_command)
        if postback_uri
          begin
            postback_xml = "<task><name>#{name}</name>" +
              "<status>#{status}</status>" +
              "<stdout>#{stdout}</stdout>" +
              "<stderr>#{stderr}</stderr></task>"
            RestClient.post postback_uri, postback_xml, :content_type => "application/xml"
          rescue Errno::ECONNREFUSED
            Kernel.puts "Couldn't post to #{postback_uri}"
          end
        end
      end

      return job
    end
  end
end
