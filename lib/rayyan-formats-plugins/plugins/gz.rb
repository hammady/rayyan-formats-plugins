require 'zlib'

module RayyanFormats
  module Plugins
    class GZ < RayyanFormats::Base
      
      title 'GZ'
      extension 'gz'
      description 'Supports a single compressed file in any of the core formats. Example: file.csv.gz, file.ris.gz'

      do_import do |body, filename, &block|
        filename.gsub!(/\.gz$/, '')
        ext = File.extname(filename).delete('.')
        ext = 'txt' if ext.length == 0
        plugin = self.match_import_plugin(ext)
        fileContent = StringIO.new(body)
        gzipped = Zlib::GzipReader.new(fileContent)
        fileContent = StringIO.new(gzipped.read).string
        gzipped.close
        plugin.do_import(fileContent, filename, &block)
      end
      
    end # class
  end # module
end # module
