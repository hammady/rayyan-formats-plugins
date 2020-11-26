require 'zlib'

module RayyanFormats
  module Plugins
    class GZ < RayyanFormats::Base

      title 'GZ'
      extension 'gz'
      description 'Supports a single compressed file in any of the core formats. Example: file.csv.gz, file.ris.gz'

      do_import do |body, filename, converter, &block|
        filename.gsub!(/\.gz$/, '')
        ext = File.extname(filename).delete('.')
        ext = 'txt' if ext.length == 0
        plugin = self.match_import_plugin(ext)
        file_content = StringIO.new(body)
        gzipped = Zlib::GzipReader.new(file_content)
        file_content = StringIO.new(gzipped.read).string
        gzipped.close
        file_content = converter.call(file_content, ext) if converter
        plugin.do_import(file_content, filename, converter, &block)
      end

    end # class
  end # module
end # module
