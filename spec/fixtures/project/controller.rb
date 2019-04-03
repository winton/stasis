# Root controller
# ---------------

require "#{File.dirname(__FILE__)}/plugin"

Stasis::Options.set_template_option 'scss', { :load_paths => ["#{File.dirname(__FILE__)}/../mixins"] }

# Before

before 'index.html.haml' do
  @before_index_literal = :root
end

before 'template_options.html.haml' do
  @css = render 'template_options.css.scss'
end

before 'no_controller/index.html.haml' do
  @before_index_literal = :no_controller
end

before /index\.html/ do
  @before_index_regexp = :root
end

before do
  @before_all = :root
end

before 'fail' do
  @fail = true
end

before /fail/ do
  @fail = true
end

before 'before_render_text.html.haml' do
  instead render(:text => 'root')
end

before 'before_render_partial.html.haml' do
  instead render(:path => '_partial.html.haml')
end

before 'before_non_existent.html' do
  instead render(:path => '_partial.html.haml')
end

before 'before_render_locals.html.haml' do
  instead render(:path => '_locals.html.haml', :locals => { :x => true })
end

# Helpers

helpers do
  def helper
    :root
  end
end

# Ignore

ignore /\/_.*/
ignore 'ignored_subdirectory/controller.rb'

# Layout

layout 'layout_controller.html.haml' => 'layout.html.haml'
layout 'layout_controller_from_subdirectory.html.haml' => 'subdirectory/layout.html.haml'

before 'layout_action.html.haml' do
  layout 'layout.html.haml'
end

before 'layout_action_false.html.haml' do
  layout false
end

before 'layout_action_from_subdirectory.html.haml' do
  layout 'subdirectory/layout.html.haml'
end

layout 'does_not_exist.html.haml'
layout 'index.html.haml' => 'does_not_exist.html.haml'

layout 'layout.html.erb'

# Priority

priority 'subdirectory/before_render_partial.html.haml' => 1
priority 'index.html.haml' => -1
priority 'does_not_exist.html.haml' => -1

before do
  $render_order ||= []
  if _stasis.path
    $render_order << _stasis.path
  end
end
