Stasis
======

Stasis is not your typical static site generator:

* Execute any Ruby code before each template is rendered
* Use cron (or any Ruby code) to regenerate pieces of your site
* Render to any number of dynamic paths

Install
-------

    gem install stasis

Example Project
---------------

    project/
        index.html.haml
        subdirectory/
            index.html.haml
            other.txt

Open terminal and run `stasis` on the project:

    $ cd project
    $ stasis

This generates a `public` directory:

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

    project/
        controller.rb
        index.html.haml
        subdirectory/
            controller.rb
            index.html.haml
            other.txt

Each controller executes once before rendering templates at the same directory level or below.

Before Filters
--------------

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

Rendering
---------

Render within a template:

    %html
      %body= render '_partial.html.haml'

Render within a `before` block:

    before 'index.html.haml' do
      @partial = render '_partial.html.haml'
    end

Render text:

    render :text => 'Hello'

Render with local variables:

    render 'index.html.haml', :locals => { :x => true }

Render with a block for the template to `yield` to:

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

Supported Template Engines
--------------------------

Stasis uses [Tilt](https://github.com/rtomayko/tilt) to support the following template engines:

    ENGINE                     FILE EXTENSIONS   REQUIRED LIBRARIES
    -------------------------- ----------------- ----------------------------
    ERB                        .erb              none (included ruby stdlib)
    Interpolated String        .str              none (included ruby core)
    Haml                       .haml             haml
    Sass                       .sass             haml
    Less CSS                   .less             less
    Builder                    .builder          builder
    Liquid                     .liquid           liquid
    RDiscount                  .markdown         rdiscount
    RedCloth                   .textile          redcloth
    RDoc                       .rdoc             rdoc
    Radius                     .radius           radius
    Markaby                    .mab              markaby
    Nokogiri                   .nokogiri         nokogiri
    CoffeeScript               .coffee           coffee-script (+node coffee)
    Slim                       .slim             slim (>= 0.7)

Automatic Regeneration
----------------------

To continuously regenerate your project as you modify files, run:

    stasis -a