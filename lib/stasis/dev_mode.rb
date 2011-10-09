gem "directory_watcher", "~> 1.4.0"
require 'directory_watcher'

class Stasis
  class DevMode

    def initialize(dir, options={})
      trap("INT") { exit }

      puts "\nDevelopment mode enabled: #{dir}"

      @dir = dir
      @options = options

      render

      dw = DirectoryWatcher.new(@stasis.root)
      dw.interval = 1

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

      dw.add_observer do |*events|
        modified = events.detect { |e| e[:type] == :modified }
        render if modified
      end

      dw.start
      loop { sleep 1000 }
    end

    private

    def render
      puts "\n[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] Regenerating #{@options[:only] ? @options[:only].join(', ') : 'project'}..."
      begin
        @stasis = Stasis.new(*[ @dir, @options[:public], @options ].compact)
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