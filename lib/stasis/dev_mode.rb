begin
  gem 'rb-fsevent'
  require 'rb-fsevent'
rescue LoadError
  gem 'directory_watcher', '1.4.1'
  require 'directory_watcher'
end

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

      if defined?(FSEvent)
        watch_directory_with_fsevent
      else
        watch_directory_with_directory_watcher
      end


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

    def watch_directory_with_fsevent
      Thread.new do
        fsevent = FSEvent.new
        @last_render_at = Time.now.to_i
        fsevent.watch(@stasis.root, :latency => 0.1) do |directories|
          # remove any directory elements that are in public
          directories.reject!{|d| d.start_with?(@stasis.destination + '/')}
          # if the only remaining directory is the root, check to see if any files were updated
          directories.clear if directories.size == 1 && 
                               directories.first == @stasis.root + '/' && 
                               Dir["#{@stasis.root}/*"].none?{|p| File.file?(p) && File.mtime(p).to_i > @last_render_at}
          # only if we have something to do, do it.
          unless directories.empty?
            render 
            @last_render_at = Time.now.to_i
          end
        end
        fsevent.run
      end
    end

    def watch_directory_with_directory_watcher
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
    end

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
