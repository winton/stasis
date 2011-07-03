require 'nokogiri'

before 'index.html.haml' do
  @readme = Nokogiri::HTML(render('../README.md')).css('body')
  @readme.children.each do |node|
    break if node.name == 'h2'
    node.remove
  end
  @readme = @readme.inner_html
end