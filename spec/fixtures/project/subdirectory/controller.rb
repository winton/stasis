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

# Destination

destination 'rename_controller.html.haml' => 'renamed_controller.html'
destination 'rename_to_root.html.haml' => '/renamed_to_root.html'

before 'rename_action.html.haml' do
  destination 'renamed_action.html'
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

layout 'layout_controller.html.haml' => 'layout.html.haml'
layout 'layout_controller_from_root.html.haml' => '/layout.html.haml'

before 'layout_action.html.haml' do
  layout 'layout.html.haml'
end

before 'layout_action_from_root.html.haml' do
  layout '/layout.html.haml'
end

# Priority

priority '/rename_to_subdirectory.html.haml' => 1
priority 'index.html.haml' => -1