class Stasis
  class Resolve
    attr_reader :name, :stasis

    def absolute
      (@name =~ /^\// && File.exist?(@name)) ? @name : nil
    end

    def relative
      f = File.expand_path("#{stasis.path}/#{@name}")
      File.exist?(f) ? f : nil
    end

    def stasisroot
      f = File.expand_path("#{stasis.root}/#{@name}")
      File.exist?(f) ? f : nil
    end

    def glob
      dirstr = ''
      dirstr = "/#{File.dirname(@name)}" if @name =~ /\//
      globstr = "#{stasis.root}#{dirstr}/{_,}#{File.basename(@name)}.*"
      match = Dir.glob(globstr)
      case match.length
      when 0 then raise "not found: #{@name}\n(glob was: Dir[#{globstr.inspect}] )"
      when 1 then match.first
      else raise "Ambiguous resolve on: #{globstr.inspect}\n#{match}\n"
      end
    end

    def real_path
      @real_path ||= (absolute || relative || stasisroot || glob)
    end

    def initialize(stasis_obj, name_str)
      @stasis = stasis_obj
      @name = name_str
    end
  end
end
