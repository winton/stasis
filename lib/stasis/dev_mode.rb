require 'listen'

require 'logger'
require 'webrick'

class Stasis
  class DevMode
    attr_reader :listener

    def initialize(dir, options={})
      trap("INT") { exit }

      puts "\nDevelopment mode enabled: ".green + dir 
      $stdout.flush

      @options = options
      @options[:development] ||= true

      @stasis = Stasis.new(*[ dir, @options[:public], @options ].compact)

      #relative_destination_path = @stasis.destination.
      @listener = Listen.to(@stasis.root)
        .change {render}

      if @stasis.destination.include?(@stasis.root)
        relative_destination_path = @stasis.destination.gsub(@stasis.root + '/', '')
        @listener.ignore Regexp.new(relative_destination_path)
      end
    end

    def run
      if @options[:development].is_a?(::Integer)
        @listener.start

        mime_types = WEBrick::HTTPUtils::DefaultMimeTypes

        additional_mime_types = @options[:mime_types]

        additional_mime_types.each do |extension, mimetype|
          mime_types.store extension, mimetype
          puts "add mime type #{mimetype} with extension .#{extension}"
        end

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
        @listener.start!
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
