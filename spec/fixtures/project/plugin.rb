class Plugin < Stasis::Plugin
  before_all :plugin

  def plugin(controller, controllers, paths)
    if controller._[:root] == controller._[:dir]
      controller.before("custom_plugin.html") do
        instead "pass"
      end
    end
    [ controller, controllers, paths ]
  end
end

Stasis.register(Plugin)