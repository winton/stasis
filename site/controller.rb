require 'albino'
require 'nokogiri'

before 'index.html.haml' do
  @readme = render('../README.md')
  @readme = Nokogiri::HTML(@readme).css('body')

  # Remove everything before the first <h2> tag
  @readme.children.each do |node|
    break if node.name == 'h2'
    node.remove
  end
  
  # Link <h2> and <h3> tags
  @links = @readme.css('h2, h3').collect do |node|
    href = node.text.downcase.gsub(/\s/, '_')
    name = node.text
    node.inner_html = '<a name="' + href + '" href="#' + href + '">' + node.inner_html + '</a>'
    if node.name == 'h2'
      { :name => name, :href => href }
    else
      nil
    end
  end
  @links.compact!
  
  @readme.css('pre').each do |pre|

    # Retrieve language and highlight info from comment
    highlight = nil
    language = nil
    comment = pre.previous.previous
    if comment && comment.comment?
      highlight = comment.content.match(/highlight:(\S+)/)
      language = comment.content.match(/language:(\S+)/)
      highlight = highlight[1].split(',') if highlight
      language = language[1] if language
    end
    highlight ||= []
    language ||= :ruby

    # Insert <pre> tags before the previous element (because its floated right)
    unless pre.previous_element.name == 'h2'
      pre.previous_element.add_previous_sibling(pre)
    end

    # Insert <div class="clear"> before each <pre> tag
    pre.add_previous_sibling('<div class="clear"></div>')

    # Pygmentize
    pygmented = Albino.colorize(pre.css('code').text, language)

    # Highlight
    highlight.each do |str|
      pygmented = pygmented.gsub(str, '<span class="sr">' + str + '</span>')
    end

    # Replace <pre>
    pre.replace pygmented
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