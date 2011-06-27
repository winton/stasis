Stasis::Gems.activate %w(eventmachine yajl-ruby)
require 'eventmachine'
require 'yajl'

class Stasis
  class Daemon

    def initialize(dir, port)
      @port = port

      last_retry = nil
      retries = 0

      puts "\nStarting Stasis daemon on port #{port}..."

      begin
        EM.epoll if EM.epoll?
        EM.run do
          EM.start_server '0.0.0.0', port, Tcp
        end
      rescue Interrupt
        shut_down
      rescue Exception => e
        puts "\nError: #{e.message}"
        puts "\t#{e.backtrace.join("\n\t")}"

        if retries >= 10 && Time.now - last_retry < 10
          shut_down
        else
          retries += 1
          last_retry = Time.now
        end
      end
    end

    def shut_down
      puts "\nShutting down Stasis daemon on port #{@port}..."
      exit
    end

    module Tcp
      def self.parser
        @parser ||= Yajl::Parser.new(:symbolize_keys => true)
      end

      def parser
        self.class.parser
      end

      def receive_data(data)
        puts parser.parse(data).inspect
        send_data "OK\n"
      end
    end
  end
end