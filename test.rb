#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rayyan-formats-core'
require 'rayyan-formats-plugins'
require 'logger'

RayyanFormats::Base.plugins = [
  RayyanFormats::Plugins::Refman,
  RayyanFormats::Plugins::EndNote,
  RayyanFormats::Plugins::BibTeX,
  RayyanFormats::Plugins::WordDocument,
  RayyanFormats::Plugins::GZ,
  RayyanFormats::Plugins::Zip,
  RayyanFormats::Plugins::CIW
]
puts RayyanFormats::Base.plugins

puts RayyanFormats::Base.send(:match_import_plugin, 'ris')
puts RayyanFormats::Base.send(:match_import_plugin, 'foo')
puts RayyanFormats::Base.send(:match_import_plugin, 'ciw')
puts RayyanFormats::Base.import_extensions_str
puts RayyanFormats::Base.export_extensions_str

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG
RayyanFormats::Base.logger = logger

puts "Exporting..."
plugin = RayyanFormats::Base.get_export_plugin('bib')
%w(
  example.bib
  example.enw
  example.ris
  example.ciw
  example.csv
  s3/endnote-example.txt
  s3/refman-example.docx
  s3/refman-example.ris.gz
  s3/zip-example.zip
).map{|filename| "../rayyan/nonrails/citation_examples/#{filename}"}.each do |filename|
  RayyanFormats::Base.import(RayyanFormats::Source.new(filename)) { |target, total|
    # post processing for target
    puts plugin.export(target)
  }
end

