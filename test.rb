#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rayyan-formats-core'
require 'rayyan-formats-plugins'
require 'log4r'

RayyanFormats::Base.formats = [
  RayyanFormats::Plugins::Refman,
  # RayyanFormats::Plugins::PubmedXML,
  RayyanFormats::Plugins::EndNote,
  RayyanFormats::Plugins::BibTeX,
  RayyanFormats::Plugins::WordDocument,
  RayyanFormats::Plugins::GZ,
  RayyanFormats::Plugins::Zip
]
puts RayyanFormats::Base.formats

begin
  puts RayyanFormats::Base.match_format('ris')
  puts RayyanFormats::Base.match_format('foo')
rescue => e
  puts "Exception: #{e.message}"
end
puts RayyanFormats::Base.extensions_str

logger = Log4r::Logger.new('RayyanFormats')
logger.outputters = Log4r::Outputter.stdout
RayyanFormats::Base.logger = logger

%w(
  example.bib
  example.enw
  example.ris
  example.csv
  s3/endnote-example.txt
  s3/refman-example.docx
  s3/refman-example.ris.gz
  s3/zip-example.zip
).map{|filename| "../rayyan/nonrails/citation_examples/#{filename}"}.each do |filename|
  RayyanFormats::Base.import(RayyanFormats::Source.new(filename)) { |target, total, is_new|
    # post processing for target
    puts "Found target: #{target}. Total: #{total}. is_new: #{is_new}"
  }
end

