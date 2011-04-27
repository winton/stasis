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

# Destination

destination 'rename_controller.html.haml' => 'renamed_controller.html'
destination 'rename_to_root.html.haml' => '/renamed_to_root.html'

before 'rename_action.html.haml' do
  destination 'renamed_action.html'
end