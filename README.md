Stasis
======

Stasis is a dynamic framework for static sites.

Install
-------

Install via [RubyGems](http://rubygems.org/pages/download):

<!-- language:console -->

    $ gem install stasis

Example
-------

At its most essential, Stasis takes a directory tree with [supported template files](#supported_markup_languages) and renders them.

Example directory structure:

<!-- language:console -->

    project/
        index.html.haml
        images/
            image.png

Run `stasis`:

<!-- highlight:stasis language:console -->

    $ cd project
    $ stasis

Stasis creates a `public` directory:

<!-- highlight:public/ language:console -->

    project/
        index.html.haml
        images/
            image.png
        public/
            index.html
            images/
                image.png

`index.html.haml` becomes `public/index.html`.

Unrecognized extensions are copied as-is (`image.png`).

Controllers
-----------

Controllers contain Ruby code that executes once before all templates render.

Example directory structure:

<!-- highlight:controller.rb language:console -->

    project/
        controller.rb
        index.html.haml
        styles/
            controller.rb
            style.css.sass
        

You may have a controller at any directory level.

Before
------

Use `before` blocks within `controller.rb` to execute code before a template renders.

`controller.rb`:

    before 'index.html.haml' do
      @something = true
    end

`@something` is now available to the `index.html.haml` template.

The `before` method can take any number of paths and/or regular expressions:

    before 'index.html.haml', /.*html\.erb/ do
      @something = true
    end

Layouts
-------

`layout.html.haml`:

    %html
      %body= yield

In `controller.rb`, set the default layout:

    layout 'layout.html.haml'

Set the layout for a particular template:

    layout 'index.html.haml' => 'layout.html.haml'

Use a regular expression:

    layout /.*html.haml/ => 'layout.html.haml'

Set the layout from a `before` block:

    before 'index.html.haml' do
      layout 'layout.html.haml'
    end

Render
------

Within a template:

    %html
      %body= render '_partial.html.haml'

Within a `before` block:

    before 'index.html.haml' do
      @partial = render '_partial.html.haml'
    end

Text:

    render :text => 'Hello'

Local variables:

    render 'index.html.haml', :locals => { :x => true }

Include a block for the template to `yield` to:

    render 'index.html.haml' { 'Hello' }

Instead
-------

The `instead` method changes the output of the template being rendered:

    before 'index.html.haml' do
      instead render('subdirectory/index.html.haml')
    end

Helpers
-------

`controller.rb`:

    helpers do
      def say_hello
        'Hello'
      end
    end

The `say_hello` method is now available to all `before` blocks and templates.

Ignore
------

Use the `ignore` method in `controller.rb` to ignore certain paths.

Ignore filenames with an underscore at the beginning:

    ignore /\/_.*/

Priority
--------

Use the `priority` method in `controller.rb` to change the file process order.

Copy `.txt` files before rendering the `index.html.erb` template:

    priority /.*txt/ => 2, 'index.html.erb' => 1

The default priority is `0` for all files.

Usage
-----

### Command Line

Always execute the `stasis` command in the root directory of your project.

Development mode (auto-regenerate on save):

<!-- highlight:-d language:console -->

    $ stasis -d

Only render specific files or directories:

<!-- highlight:-o language:console -->

    $ stasis -o index.html.haml,subdirectory

Change the public (destination) directory:

<!-- highlight:-o language:console -->

    $ stasis -p ../public
   
### Ruby Library

Instantiate a `Stasis` object:

    stasis = Stasis.new('/path/to/project/root')

Optionally specify a destination directory:

    stasis = Stasis.new('/project', '/html')

Render all templates:

    stasis.render

Render a specific template or directory:

    stasis.render('index.html.haml', 'subdirectory')

More
----

### Supported Markup Languages

Stasis uses [Tilt](https://github.com/rtomayko/tilt) to support the following template engines:

<!-- language:console -->

    ENGINE                     FILE EXTENSIONS
    -------------------------- -----------------------
    ERB                        .erb, .rhtml
    Interpolated String        .str
    Erubis                     .erb, .rhtml, .erubis
    Haml                       .haml
    Sass                       .sass
    Scss                       .scss
    Less CSS                   .less
    Builder                    .builder
    Liquid                     .liquid
    RDiscount                  .markdown, .mkd, .md
    Redcarpet                  .markdown, .mkd, .md
    BlueCloth                  .markdown, .mkd, .md
    Kramdown                   .markdown, .mkd, .md
    Maruku                     .markdown, .mkd, .md
    RedCloth                   .textile
    RDoc                       .rdoc
    Radius                     .radius
    Markaby                    .mab
    Nokogiri                   .nokogiri
    CoffeeScript               .coffee
    Creole (Wiki markup)       .wiki, .creole
    WikiCloth (Wiki markup)    .wiki, .mediawiki, .mw
    Yajl                       .yajl

### Server Mode

Stasis can run as a server that uses [redis](http://redis.io) to wait for render jobs.

Stasis server that uses redis on port 6379:

<!-- highlight:-s language:console -->

    $ stasis -s localhost:6379/0

Push to the server (in Ruby):

    Stasis::Server.push(
      # Paths to render
      :paths => [ "index.html.haml", "subdirectory" ],

      # Redis address
      :redis => "localhost:6379/0",

      # Return rendered templates (false by default)
      :return => false,

      # Block until templates generate (false by default)
      :wait => false,

      # Write to the filesystem (true by default)
      :write => true
    )

### This Web Site

[Take a look at the Stasis project](https://github.com/winton/stasis/tree/master/site) that automatically generated this web site from the project [README](https://github.com/winton/stasis/blob/master/README.md).