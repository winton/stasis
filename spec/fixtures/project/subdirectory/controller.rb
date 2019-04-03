# Subdirectory controller
# -----------------------

# Before

before 'index.html.haml' do
  @before_index_literal = :subdirectory
end

before /index\.html/ do
  @before_index_regexp = :subdirectory
end

before do
  @before_all = :subdirectory
end

before 'fail' do
  @fail = true
end

before /fail/ do
  @fail = true
end

before 'before_render_text.html.haml' do
  instead render(:text => 'subdirectory')
end

before 'before_render_partial.html.haml', 'before_non_existent.html' do
  instead render(:path => '_partial.html.haml')
end

before 'before_render_locals.html.haml' do
  instead render(:path => '_locals.html.haml', :locals => { :x => true })
end

# Helpers

helpers do
  def helper
    :subdirectory
  end
end

# Ignore

ignore 'ignore.html.haml'

# Layout

layout(
  'layout_controller.html.haml' => 'layout.html.haml',
  'layout_controller_from_root.html.haml' => '/layout.html.haml'
)

before 'layout_action.html.haml' do
  layout 'layout.html.haml'
end

before 'layout_action_false.html.haml' do
  layout false
end

before 'layout_action_from_root.html.haml' do
  layout '/layout.html.haml'
end

# Priority

priority(
  '/before_render_partial.html.haml' => 1,
  'index.html.haml' => -1
)
