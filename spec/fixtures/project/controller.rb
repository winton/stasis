before 'layout.erb' do
  @ignore = true
end

before 'view.erb' do
  @layout = 'layout.erb'
  @title = 'My Site'
end

helpers do
  def blah
    '!!!'
  end
end