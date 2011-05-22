Stasis
======

An extensible static site generator.

Philosophy
----------

Stasis is a perfect complement to modern dynamic frameworks:

1. Use Stasis to generate your HTML and other assets.
2. Serve that data in the most performant way possible (usually Nginx).
3. Use your dynamic framework to serve data to the client (usually JSON).
4. Use your dynamic framework (or `cron`) to regenerate Stasis pages as needed.

Stasis is not your typical "one to one" markup renderer. Render to any number of dynamic paths. Access your database. Pull data from an API. Get crazy.

Requirements
------------

    gem install stasis

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

Example
-------

The [spec project](https://github.com/winton/stasis/tree/master/spec/fixtures/project) implements all of the features in this README.

Get Started
-----------

Create a directory for your project, and within that directory, a markup file:

### view.html.erb

    Welcome <%= '!' * 3 %>

Generate Static Files
---------------------

Open your terminal, `cd` into your project directory, and run the `stasis` command:

    stasis

You now have a `public` directory with rendered markup:

    public/
      view.html
    view.html.erb

If the file extension is a supported markup file, it renders into `public`.

If the file extension is unsupported, it copies into `public`.

Controllers
-----------

The only reserved filename in a Stasis project is `controller.rb`.

You can have a `controller.rb` at any directory level:

    controller.rb
    index.html.erb
    pages/
      controller.rb
      page.html.erb

Controllers at the same directory level or above execute for a particular markup file.

For example, `page.html.erb` uses both controllers, but `index.html.erb` only uses the top-level controller.

Callbacks
---------

Define `before` and `after` render callbacks within your controller:

### controller.rb

    # Call before any file renders
    
    before do
      @what_is_rendering = "any file"
    end

    # Call before any ERB file renders
    
    before /.*erb/ do
      @what_is_rendering = "ERB file"
    end
    
    # Call only before view.html.erb renders
    
    before 'view.html.erb' do
      @what_is_rendering = "the view"
    end

### view.html.erb

    <%= @what_is_rendering %>

Change the Destination
----------------------

Let's say we want `view.html.erb` to be our front page:

### controller.rb

    destination 'view.html.erb' => '/index.html'
    
    # or
    
    before 'view.html.erb' do
      @destination = '/index.html'
    end

Ignore
------

Sometimes you will want to ignore certain files entirely (no render, no copy).

For example, you'll often want to ignore filenames with an underscore at the beginning (partials):

### controller.rb

    ignore /_.*/

    # or

    before /_.*/ do
      @ignore = true
    end

Layouts
-------

Create the layout markup:

### layout.html.erb

    <html>
      <body><%= yield %></body>
    </html>

### controller.rb

    # set default layout for all views

    layout 'layout.html.erb'

    # or set layout for specific view

    layout 'view.html.erb' => 'layout.html.erb'
    
    # or
    
    before 'view.html.erb' do
      @layout = 'layout.html.erb'
    end

Layout files are automatically ignored (don't want to render a `layout.html` file).

Helpers
-------

Define helper methods within your controllers.

### controller.rb

    helpers do
      def active?(path)
        @source == path
      end
    end

### layout.html.erb

    <% if active?('view.html.erb') %>
      Rendering view.html.erb
    <% end -%>

Priority
--------

You may want some files to render or copy before others:

### controller.rb

    priority 'view.html.erb' => 1, /.*css/ => 2, /.*js/ => 2

The default priority is `0`.

Rendering
---------

Render other files within a callback, helper, or view:

### view.html.erb

    <%= render '_partial.html.erb', :locals => { :x => 'y' } %>

Summary
-------

Use the following methods in your controllers:

* `after`
* `before`
* `destination`
* `ignore`
* `layout`
* `priority`

Use the following methods within a callback, helper, or view:

* `render`

Use the following class variables in your callbacks, helpers, or views:

* `@destination`
* `@layout`
* `@source`

Only alter these class variables from a `before` callback.

Continuous Rendering
--------------------

To continuously render files as you change them, run:

    stasis -c

Web Server
----------

To start Stasis in web server mode, run:

    stasis -p 3000

In your browser, visit [http://localhost:3000](http://localhost:3000).

In web server mode, Stasis continuously renders (`-c`).

Other Topics:
-------------

* [Asset Packaging](https://github.com/winton/stasis/wiki/Asset-Packaging)
* [Callback Execution Order](https://github.com/winton/stasis/wiki/Callback-Execution-Order).
* [Run Stasis Programmatically](https://github.com/winton/stasis/wiki/Run-Stasis-Programmatically)