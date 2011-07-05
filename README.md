Stasis
======

Stasis is a dynamic framework for static sites.

When coupled with [metastasis](https://github.com/winton/metastasis), Stasis can even respond to dynamic user input.

The end goal? Making a high-performance web framework that serves pages solely through Nginx.

Install
-------

Install via RubyGems:

<!-- language:console -->

    $ gem install stasis

Verify the install:

<!-- language:console -->

    $ stasis -h

Templates
---------

Example directory structure:

<!-- language:console -->

    project/
        index.html.haml
        subdirectory/
            index.html.haml
            other.txt

Open terminal and run `stasis`:

<!-- language:console -->

    $ cd project
    $ stasis

You now have a `public` directory:

<!-- language:console -->

    project/
        public/
            index.html
            subdirectory/
                index.html
                other.txt

Templates (`*.html.haml`) are rendered and the template extension is removed.

Because `.txt` is not a supported template extension, Stasis copies `other.txt` and does nothing further to it.

Controllers
-----------

Let's add controllers to the project:

<!-- language:console -->

    project/
        controller.rb
        index.html.haml
        subdirectory/
            controller.rb
            index.html.haml
            other.txt

Each controller executes once before rendering templates at the same directory level or below.

Before
------

In your controller:

    before 'index.html.haml' do
      @something = true
    end

The class variable `@something` is made available to the `index.html.haml` template.

The `before` method can take any number of paths and/or regular expressions.

Layouts
-------

Create a `layout.html.haml` template:

    %html
      %body= yield

In your controller, set the default layout:

    layout 'layout.html.haml'

Set the layout for a particular template:

    layout 'index.html.haml' => 'layout.html.haml'

Or use a regular expression:

    layout /.*.html.haml/ => 'layout.html.haml'

Set the layout from a `before` filter if you like:

    before 'index.html.haml' do
      layout 'layout.html.haml'
    end

Ignore
------

Use the `ignore` method in your controller to ignore certain paths.

For example, to ignore paths with an underscore at the beginning (partials):

    ignore /_.*/

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

To make methods available to `before` callbacks and templates, add a `helpers` block to your controller:

    helpers do
      def say_hello
        'Hello'
      end
    end

Priority
--------

Change the order in which files are rendered or copied:

    priority 'index.html.erb' => 1, /.*\.txt/ => 2

In this example, text files are copied to `public` before `index.html.erb` renders.

The default priority is `0`.

More
----

### Automatic Regeneration

To continuously regenerate your project as you modify files, run:

<!-- language:console -->

    $ stasis -a

### Supported Markup Languages

Stasis uses [Tilt](https://github.com/rtomayko/tilt) to support the following template engines:

<!-- language:console -->

    ENGINE                     FILE EXTENSIONS
    -------------------------- ----------------------
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
    Creole (Wiki markup)       .creole
    Yajl                       .yajl