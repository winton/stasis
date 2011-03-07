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

A controller defines `before` and `after` render callbacks.

The only reserved filename in a Stasis project is `controller.rb`.

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

### Multiple Controllers

You can have a `controller.rb` at any directory level:

    controller.rb
    index.erb
    pages/
      controller.rb
      page.erb

This allows you to better organize your callbacks.

Read more about [callback execution order](https://github.com/winton/stasis/wiki/Callback-Execution-Order).

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
      @ignore = true
    end

We want `view.erb` to use the layout, so we set `@layout = 'layout.erb'`.

We do not want a `public/layout.html` file, so we set `@ignore = true`.

Change the Path
---------------

Let's say we want `view.erb` to be our front page.

### controller.rb

    before 'view.erb' do
      @path = '/'
    end

Adding `@path = '/'` changes the render location to `public/index.html`.

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

Programmatically Generate Content
---------------------------------

    require 'rubygems'
    require 'stasis'
    
    stasis = Stasis.new '/path/to/project'
    
    # Generate all files
    stasis.generate '**/*'
    
    # Generate one file
    stasis.generate 'view.erb'
    
    # Generate one file with extra callbacks
    stasis.generate 'view.erb' do
      before do
        @path = "/custom/path"
      end
    end

Extra callbacks execute before any filters defined in the project.