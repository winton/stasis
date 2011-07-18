class Plugin < Stasis::Plugin

  before_all :plugin

  def initialize(stasis)
  	@stasis = stasis
  end

  def plugin
    @stasis.controller.before("custom_plugin.html") do
      instead "pass"
    end
  end
end

Stasis.register(Plugin)