# Ignore partials
ignore /\/_.*/

helpers do
  def link_to(href, value)
    '<a href="' + href + '">' + value + '</a>'
  end
end