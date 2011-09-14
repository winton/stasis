class Stasis
  class Options

    @@template_options = Hash.new

    # Set template engine options.
    #
    # type: string, template extension, e.g 'haml'
    # opts: hash, template options
    def self.set_template_option(type, opts={})
        @@template_options[type] = opts
    end

    # Retrieve template engine options if available.
    # Returns empty hash if no options set.
    def self.get_template_option(type)
        @@template_options[type] || {}
    end

  end
end
