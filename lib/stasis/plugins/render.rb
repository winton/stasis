require 'tilt'

class Stasis
  class Render < Plugin

    action_method :render

    def render(action, path, options={})
      if Tilt.mappings.keys.include?(File.extname(path)[1..-1])
        options[:context] ||= action
        Tilt.new(path).render(options[:context], options[:locals])
      else
        File.read(path)
      end
    end
  end
end