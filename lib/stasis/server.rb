Stasis::Gems.activate %w(redis yajl-ruby)

require 'digest/sha1'
require 'redis'
require 'yajl'

class Stasis
  class Server

    def initialize(root, options={})
      puts "\nStarting Stasis server (redis @ #{options[:server]})..."

      redis = Redis.connect(:url => "redis://#{options[:server]}")
      stasis = Stasis.new(root)

      begin
        while true
          sleep(1.0 / 1000.0)
          request = redis.lpop('stasis:requests')

          if request
            request = Yajl::Parser.parse(request)

            files = stasis.render(
              *request['paths'],
              :collect => request['return'],
              :locals => request['locals']
            )

            if request['return'] && request['paths'] && !request['paths'].empty?
              request['wait'] = true
            end

            if request['wait']
              response = {
                :id => request['id'],
                :files => files
              }
              redis.publish(self.class.response_key(request['id']), Yajl::Encoder.encode(response))
            end
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
      puts "\nShutting down Stasis server..."
      exit
    end

    class <<self
      def push(options)
        options[:id] = Digest::SHA1.hexdigest("#{options['paths']}#{Random.rand}")
        redis_url = "redis://#{options.delete(:redis) || "localhost:6379/0"}"
        response = nil

        redis_1 = Redis.connect(:url => redis_url)
        redis_2 = Redis.connect(:url => redis_url)

        if options[:return] || options[:wait]
          redis_1.subscribe(response_key(options[:id])) do |on|
            on.subscribe do |channel, subscriptions|
              redis_2.rpush("stasis:requests", Yajl::Encoder.encode(options))
            end

            on.message do |channel, message|
              response = Yajl::Parser.parse(message)
              redis_1.unsubscribe
            end
          end
        else
          redis_1.rpush("stasis:requests", Yajl::Encoder.encode(options))
        end

        redis_1.quit
        redis_2.quit

        response
      end

      def response_key(id)
        "stasis:response:#{id}"
      end
    end
  end
end