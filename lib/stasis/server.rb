Stasis::Gems.activate %w(redis yajl-ruby)

require 'redis'
require 'yajl'

class Stasis
  class Server

    def initialize(options={})
      puts "\nStarting Stasis daemon (redis @ #{options[:redis]})..."

      host, port = options[:redis].split(':')
      redis = Redis.new(:host => host, :port => port)
      stasis = Stasis.new(Dir.pwd)

      begin
        while true
          sleep(1.0 / 1000.0)
          data = redis.lpop('stasis:requests')
          if data
            data = Yajl::Parser.parse(data)
            # stasis.generate(
            #   :only => data['request_uri']
            # )
            puts data.inspect
          end
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