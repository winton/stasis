gem 'directory_watcher', '1.4.1'
require 'directory_watcher'

require 'logger'
require 'webrick'

class Stasis
  class DevMode

    def initialize(dir, options={})
      trap("INT") { exit }

      puts "\nDevelopment mode enabled: ".green + dir 
      $stdout.flush

      @options = options
      @options[:development] ||= true

      @stasis = Stasis.new(*[ dir, @options[:public], @options ].compact)

      glob =
        Dir.chdir(@stasis.root) do
          # If destination is within root
          if @stasis.destination[0..@stasis.root.length] == "#{@stasis.root}/"
            relative = @stasis.destination[@stasis.root.length+1..-1] rescue nil
            Dir["*"].inject(["*"]) do |array, path|
              if File.directory?(path) && path != relative
                array.push("#{path}/**/*")
              end
              array
            end
          else
            [ "*", "**/*" ]
          end
        end

      dw = DirectoryWatcher.new(@stasis.root)
      dw.add_observer { render }
      dw.glob = glob
      dw.interval = 0.1
      dw.start

      if @options[:development].is_a?(::Integer)
        mime_types = WEBrick::HTTPUtils::DefaultMimeTypes
        mime_types.store 'js', 'application/javascript'
        
        server  = WEBrick::HTTPServer.new(
          :AccessLog => [ nil, nil ],
          :DocumentRoot => @stasis.destination,
          :Logger => WEBrick::Log.new(
            (RUBY_PLATFORM =~ /mswin|mingw/) ? 'NUL:' : '/dev/null'
          ),
          :MimeTypes => mime_types,
          :Port => @options[:development]
        )
        
        ['INT', 'TERM'].each do |signal|
          trap(signal) { server.shutdown }
        end

        server.start
      else
        loop { sleep 1 }
      end
    end

    private

    def render
      puts "\n[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]" + " Regenerating #{@options[:only] ? @options[:only].join(', ') : 'project'}...".yellow
      begin
        @stasis.load_paths
        @stasis.trigger(:reset)
        @stasis.load_controllers
        @stasis.render(*[ @options[:only] ].flatten.compact)
      rescue Exception => e
        puts "\n[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]" + " Error: #{e.message}`".red
        puts "\t#{e.backtrace.join("\n\t")}"
      else
        puts "\n[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]" + " Complete".green
      end
      $stdout.flush
    end
  end
end
