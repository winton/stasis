require 'albino'
require 'nokogiri'

before 'index.html.haml' do
  @readme = Nokogiri::HTML(render('../README.md')).css('body')

  # Remove everything before the first <h2> tag
  @readme.children.each do |node|
    break if node.name == 'h2'
    node.remove
  end
  
  # Link <h2> tags
  @links = @readme.css('h2').collect do |node|
    href = node.text.downcase
    name = node.text
    node.inner_html = '<a name="' + href + '" href="#' + href + '">' + node.inner_html + '</a>'
    { :name => name, :href => href }
  end
  
  @readme.css('pre').each do |pre|

    # Retrieve language from comment
    language = nil
    comment = pre.previous.previous
    if comment && comment.comment?
      language = comment.content.strip.split('language:')[1]
    end
    language ||= :ruby

    # Insert <pre> tags before the previous element (because its floated right)
    unless pre.previous_element.name == 'h2'
      pre.previous_element.add_previous_sibling(pre)
    end

    # Insert <div class="clear"> before each <pre> tag
    pre.add_previous_sibling('<div class="clear"></div>')

    # Pygmentize
    pre.replace Albino.colorize(pre.css('code').text, language)
  end
  
  # Insert <div class="clear"> before each <h3> tag
  @readme.css('h3').each do |h3|
    h3.add_previous_sibling('<div class="clear"></div>')
  end
  
  # Replace colons at the end of <p> tags with arrows.
  @readme.css('p').each do |p|
    p.inner_html = p.inner_html.strip.gsub(/:$/, '<img src="arrow.png" class="arrow" />')
  end
  
  @readme = @readme.inner_html
end