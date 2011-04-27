# Before

before 'index.html.haml' do
  @before_index_literal = :root
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

# Destination

destination 'rename_controller.html.haml' => 'renamed_controller.html'
destination 'rename_to_subdirectory.html.haml' => 'subdirectory/renamed_to_subdirectory.html'

before 'rename_action.html.haml' do
  destination 'renamed_action.html'
end