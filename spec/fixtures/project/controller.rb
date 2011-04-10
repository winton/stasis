ignore 'layout.html.erb'
layout 'layout.html.erb'
priority /.*erb/ => 1

before 'view.html.erb' do
  #layout 'layout.html.erb'
  @title = 'My Site'
end

helpers do
  def blah
    '!!!'
  end
end