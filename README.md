Stasis
======

A general-purpose static site generator.

Philosophy
----------

My preferred stack = static markup/assets (Nginx) + services (Node.js).

Stasis helps with the first part of the equation. It can even get fairly dynamic if you need it to.

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

Our [spec project](https://github.com/winton/stasis/tree/master/spec/fixtures/project) implements all the features below.

Get Started
-----------

Create a directory for your project and a markup file:

### view.erb

    Welcome <%= '!' * 3 %>

Generate Static Files
---------------------

Open your terminal, `cd` into your project directory, and run the `stasis` command:

    stasis

You now have a `public` directory with rendered markup:

    public/
      view.html
    view.erb

Controllers
-----------

The only reserved filename in a Stasis project is `controller.rb`.

You can have a `controller.rb` at any directory level:

    controller.rb
    index.erb
    pages/
      controller.rb
      page.erb

Callbacks
---------

Define `before` and `after` render callbacks within your controller:

### controller.rb

    # Call before any file renders
    
    before do
      @title = 'Default Title'
    end
    
    # Call only before view.erb renders
    
    before 'view.erb' do
      @title = 'My Site'
    end

### view.erb

    Welcome to <%= @title %>!

Change the Destination
----------------------

Let's say we want `view.erb` to be our front page:

### controller.rb

    before 'view.erb' do
      @destination = '/index.html'
    end

Layouts
-------

Create the layout markup:

### layout.erb

    <html>
      <head>
        <title><%= @title %></title>
      </head>
      <body><%= yield %></body>
    </html>

### controller.rb

    before 'view.erb' do
      @layout = 'layout.erb'
      @title = 'My Site'
    end
    
    before 'layout.erb' do
      @destination = nil
    end

We want `view.erb` to use the layout, so we set `@layout = 'layout.erb'`.

We do not want a `public/layout.html` file, so we set `@destination = nil`.

Helpers
-------

Define helper methods within your controllers.

### controller.rb

    helpers do
      def active?(path)
        @source == path
      end
    end

### layout.erb

    <%= active?('view.erb') %>

Class Variables
---------------

To summarize, the following class variables have a special purpose in a Stasis project:

* `@destination` - Get/set the destination path within `public/`
* `@layout` - Get/set a file path to use as the layout
* `@source` - Get/set the file path that is being rendered

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

* [Callback Execution Order](https://github.com/winton/stasis/wiki/Callback-Execution-Order).
* [Run Stasis Programmatically](https://github.com/winton/stasis/wiki/Run-Stasis-Programmatically)