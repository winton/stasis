# Root controller
# ---------------

require "#{File.dirname(__FILE__)}/plugin"

# Before

before 'index.html.haml' do
  @before_index_literal = :root
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

# Helpers

helpers do
  def helper
    :root
  end
end

# Ignore

ignore /\/_.*/

# Layout

layout 'layout_controller.html.haml' => 'layout.html.haml'
layout 'layout_controller_from_subdirectory.html.haml' => 'subdirectory/layout.html.haml'

before 'layout_action.html.haml' do
  layout 'layout.html.haml'
end

before 'layout_action_from_subdirectory.html.haml' do
  layout 'subdirectory/layout.html.haml'
end

# Priority

priority 'subdirectory/before_render_partial.html.haml' => 1
priority 'index.html.haml' => -1

before do
  $render_order ||= []
  $render_order << _stasis.path
end