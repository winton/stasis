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