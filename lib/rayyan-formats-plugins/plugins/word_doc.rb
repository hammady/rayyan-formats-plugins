require 'docx'

module RayyanFormats
  module Plugins
    class WordDocument < RayyanFormats::Base
      
      title 'Word Document'
      extension 'docx'
      description 'Supports text only in one of the core formats.'

      do_import do |body, filename, &block|
        begin
          tmpfile = Tempfile.new ''
          tmpfile.binmode
          tmpfile.write(body)
          tmpfile.close
          doc = ::Docx::Document.open(tmpfile.path)
          self.text_format.do_import(doc.text, filename, &block)
        end
      end
      
    end # class
  end # module
end # module