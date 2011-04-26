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

