gem "directory_watcher", "~> 1.4.1"
require 'directory_watcher'

require 'logger'
require 'webrick'

class Stasis
  class DevMode

    def initialize(dir, options={})
      trap("INT") { exit }

      puts "\nDevelopment mode enabled: #{dir}"

      @dir = dir
      @options = options

      @stasis = Stasis.new(*[ @dir, @options[:public], @options ].compact)

      dw = DirectoryWatcher.new(@stasis.root)
      dw.interval = 0.1

      Dir.chdir(@stasis.root) do
        within_public = @stasis.destination[0..@stasis.root.length-1] == @stasis.root
        rel_public = @stasis.destination[@stasis.root.length+1..-1] rescue nil
        dw.glob = Dir["*"].inject(["*"]) do |array, path|
          if File.directory?(path) && (!within_public || path != rel_public)
            array << "#{path}/**/*"
          end
          array
        end
      end

      dw.add_observer { render }
      dw.start

      if options[:development]
        mime_types = WEBrick::HTTPUtils::DefaultMimeTypes
        mime_types.store 'js', 'application/javascript'

        server = WEBrick::HTTPServer.new(
          :AccessLog => [ nil, nil ],
          :DocumentRoot => @stasis.destination,
          :Logger => WEBrick::Log.new("/dev/null"),
          :MimeTypes => mime_types,
          :Port => options[:development] || 3000
        )
        
        ['INT', 'TERM'].each do |signal|
          trap(signal) { server.shutdown }
        end

        server.start
      else
        loop { sleep 1000 }
      end
    end

    private

    def render
      puts "\n[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] Regenerating #{@options[:only] ? @options[:only].join(', ') : 'project'}..."
      begin
        @stasis.trigger(:reset)
        @stasis.load_controllers
        @stasis.render(*[ @options[:only] ].flatten.compact)
      rescue Exception => e
        puts "\n[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] Error: #{e.message}`"
        puts "\t#{e.backtrace.join("\n\t")}"
      else
        puts "\n[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] Complete"
      end
    end
  end
end
