Stasis::Gems.activate %w(beanstalk-client yajl-ruby)

require 'beanstalk-client'
require 'yajl'

class Stasis
  class Daemon

    def initialize(options={})
      puts "\nStarting Stasis daemon (beanstalk @ #{options[:beanstalk].join(', ')})..."

      beanstalk = Beanstalk::Pool.new(options[:beanstalk])

      begin
        while true
          sleep(1.0 / 1000.0)
          job = beanstalk.reserve
          data = Yajl::Parser.parse(job.body)
          puts data.inspect
          job.delete
        end
      rescue Interrupt
        shut_down
      rescue Exception => e
        puts "\nError: #{e.message}"
        puts "\t#{e.backtrace.join("\n\t")}"
        retry
      end
    end

    def shut_down
      puts "\nShutting down Stasis daemon..."
      exit
    end
  end
end