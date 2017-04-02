require 'zlib'

module RayyanFormats
  module Plugins
    class GZ < RayyanFormats::Base
      
      title 'GZ'
      extension 'gz'
      description 'Supports a single compressed file in any of the above mentioned formats. Example: file.csv.gz, file.bib.gz'

      parse do |body, filename, &block|
        filename.gsub!(/\.gz$/, '')
        ext = File.extname(filename).delete('.')
        format = self.match_format(ext)
        fileContent = StringIO.new(body)
        gzipped = Zlib::GzipReader.new(fileContent)
        fileContent = StringIO.new(gzipped.read).string
        gzipped.close
        format.parse(fileContent, filename, &block)
      end
      
    end # class
  end # module
end # module
