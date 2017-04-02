module RayyanFormats
  module Plugins
    class Zip < RayyanFormats::Base
      
      title 'ZIP'
      extension 'zip'
      description 'Supports compressed zip archives containing multiple files in any of the above mentioned formats'

      parse do |body, filename, &block|
        require 'zip'

        # Need to write file to Disk as RubyZip Input Stream doesnt read more than
        # a single entry from Zips Created by Mac
        begin
          tmpfile = Tempfile.new ''
          tmpfile.binmode
          tmpfile.write(body)
          tmpfile.close
          valid_entries = 0
          Zip::File.open(tmpfile.path) do |zip_file|
            grand_total = 0
            zip_file.each do |entry|
              # Rails.logger.debug "Extracting #{entry.name}"
              next if entry.name.include?('__MACOS')
              begin
                entry_total = nil
                ext = File.extname(entry.name).delete('.')
                format = self.match_format(ext)
                format.parse(entry.get_input_stream.read, entry.name) do |*arguments|
                  if entry_total.nil?
                    # first yielded article in entry
                    entry_total = arguments[1]
                    grand_total += entry_total
                  end
                  arguments[1] = grand_total
                  block.call(*arguments)
                end
                valid_entries += 1
              rescue => e
                # invalid ext or invalid content
              end
            end
          end
          raise "Zip file has no valid entries" if valid_entries == 0
          # Rails.logger.debug "Successfully extracted #{valid_entries} entry from zip file #{filename}"
        ensure
          tmpfile.close
        end

        # Zip::InputStream Doesnt Work with Zips Created by Macs
        # Zip::InputStream.open(StringIO.new(body)) do |io|
        #   while (entry = io.get_next_entry)
        #     ext = File.extname(entry.name).delete('.')
        #     format = self.match_format(ext) rescue next
        #     format.parse(io.read, entry.name, &block)
        #   end
        # end  
      end
      
    end # class
  end # module
end # module
