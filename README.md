[![Build Status](https://travis-ci.org/rayyansys/rayyan-formats-plugins.svg?branch=master)](https://travis-ci.org/rayyansys/rayyan-formats-plugins)
[![Coverage Status](https://coveralls.io/repos/github/rayyansys/rayyan-formats-plugins/badge.svg?branch=master)](https://coveralls.io/github/rayyansys/rayyan-formats-plugins?branch=master)

# RayyanFormats Plugins

Plugins for RayyanFormats. For details, please check the core plugin [rayyan-formats-core](https://github.com/rayyansys/rayyan-formats-core).

## Installation

Add this line to your application's Gemfile:

    gem 'rayyan-formats-plugins'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rayyan-formats-plugins

## Usage

To configure your client application to use some or all of the format plugins here, call the `plugins` method. Typically, in Rails, this is done in an initializer:

    # config/initializers/rayyan-formats.rb
    RayyanFormats::Base.plugins = [
      RayyanFormats::Plugins::Refman,
      RayyanFormats::Plugins::EndNote,
      RayyanFormats::Plugins::BibTeX
    ]

Or if you want all available plugins to be enabled:

    RayyanFormats::Base.plugins = RayyanFormats::Base.available_plugins

The rest is done exactly the same as what is explained in the core plugin.

## Development and Testing

To build for local development and testing (requires Docker):

```bash
docker build . -t rayyan-formats-plugins:1
```

To run the tests:

```bash
docker run -it --rm -v $PWD:/home rayyan-formats-plugins:1
```

This will allow you to edit files and re-run the tests without rebuilding
the image.

## Publishing the gem

```bash
docker build . -t rayyan-formats-plugins:1
docker run -it --rm rayyan-formats-plugins:1 /home/publish.sh
```

Enter your email and password when prompted. If you want to skip interactive
login, supply `RUBYGEMS_API_KEY` as an additional argument:

```bash
docker run -it --rm -e RUBYGEMS_API_KEY=YOUR_RUBYGEMS_API_KEY rayyan-formats-plugins:1 /home/publish.sh
```

## Adding more formats

Support for more formats can be done by subclassing `RayyanFormats::Base` and defining attributes and logic using simple DSL. The `detect` block is optional
and if omitted will mark the plugin as non-core. This means that it won't go
through the detection pipeline and the `do_import` block will be executed
directly if the extension matches.
Core plugins, on the other hand, pass through the detection pipeline
and must return `true` from the `detect` block for the `do_import` to be executed.

If the plugin supports exporting as well, you must define a `do_export` block.
Note that a plugin can support importing only, exporting only or both.

    module RayyanFormats
      module Plugins
        class YourNewFormat < RayyanFormats::Base

          title 'Format friendly name'
          extension 'extension here, e.g. xyz'
          description 'Description for the format'

          detect do |first_line, lines|
            if seems_ok_logic(first_line)
                next true
            else
                next false
            end
          end

          do_import do |body, filename, &block|
              resulting_articles = parse_body_logic(body)
              ...
              total = resulting_articles.length
              resulting_articles.each do |article|
                  target = Target.new
                  target.sid = article[:key]
                  target.title = article[:title]
                  ...
                  block.call(target, total)
              end
          end

          do_export do |target, options|
            # return a string representing the target in the specified format
            "#{target.key}: #{target.title}\n"  # only an example
          end

        end
      end
    end

The `options` hash that the `do_export` accept can have the following keys:

- `include_header: boolean` will be passed as `true` on the first target
and `false` on the subsequent targets. If the format supports headers (e.g. CSV)
then you must return the header concatenated before the target string representation.
- `include_abstracts: boolean` denoting whether the client program wants
the abstracts to be emitted.
- `unique_id: <generated-unique-string>` will be passed everytime in case
the format must emit a unique target identifier if not present already in the target.

The source of this gem contains several examples that you can build on.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
