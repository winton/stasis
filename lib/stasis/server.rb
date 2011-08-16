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
            files = nil

            puts request.inspect
            stasis.render(*request['paths'], :locals => request['locals'])

            if request['return'] && request['paths'] && !request['paths'].empty?
              files = request['paths'].inject({}) do |hash, path|
                path = "#{root}/public/#{path}"
                puts path
                hash[path] = File.read(path) if File.file?(path)
                hash
              end
              request['wait'] = true
            end

            if request['wait']
              response = {
                :id => request['id'],
                :files => files
              }
              redis.publish(self.class.response_key(request['id']), Yajl::Encoder.encode(response))
            end

            puts response.inspect
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
        redis = options.delete(:redis)
        response = nil

        redis.rpush("stasis:requests", Yajl::Encoder.encode(options))

        if options[:return] || options[:wait]
          redis.subscribe(response_key(options[:id])) do |on|
            on.subscribe do |channel, subscriptions|
              
            end

            on.message do |channel, message|
              response = Yajl::Parser.parse(message)
              redis.unsubscribe
            end
          end
        end

        response
      end

      def response_key(id)
        "stasis:response:#{id}"
      end
    end
  end
end