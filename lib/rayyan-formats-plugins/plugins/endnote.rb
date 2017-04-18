require 'ref_parsers'

module RayyanFormats
  module Plugins
    class EndNote < RayyanFormats::Base
      
      title 'EndNote'
      extension 'enw'
      description 'Supports entries of type Journal Article, full documentation here: http://www.harzing.com/pophelp/exporting.htm#endnote and here: http://wiki.cns.iu.edu/pages/viewpage.action?pageId=1933370'

      detect do |first_line, lines|
        first_line.start_with?('%0')
      end

      do_import do |body, filename, &block|
        articles = ::RefParsers::EndNoteParser.new.parse(body)
        total = articles.length

        # articles.select{|entry| entry['type'] == 'Journal Article'}.each do |article|
        articles.each do |article|
          target = Target.new
          target.title = article['T']
          target.date_array = get_date_array article
          target.jvolume = article['V'].to_i rescue 0
          target.pagination = article['P']
          target.authors = get_authors article
          target.abstracts = [article['X']].flatten.compact
          target.jissue = article['N'].to_i rescue 0
          target.url = article['U'] || article['>']
          target.publication_types = [article['type']]
          target.publisher_name = article['I']
          target.publisher_location = article['C']
          target.journal_title = article['J'] || article['B']
          target.journal_issn = article['@']
          target.language = article['G']
          target.notes = try_join_arr article['1']

          block.call(target, total)
        end
      end

      do_export do |target, options|
        [
          emit_line("0", target.publication_types.first),
          emit_line("T", target.title),
          target.authors ? target.authors.map{|author| emit_line("A", author)} : nil,
          emit_line("J", target.journal_title),
          target.jvolume && target.jvolume > 0 ? emit_line("V", target.jvolume) : nil,
          target.jissue && target.jissue > 0 ? emit_line("N", target.jissue) : nil,
          target.date_array ? emit_line("D", target.date_array.first) : nil,
          target.date_array ? emit_line("8", target.date_array.join("-")) : nil,
          emit_line("U", target.url),
          emit_line("I", target.publisher_name),
          emit_line("C", target.publisher_location),
          emit_line("P", target.pagination),
          emit_line("G", target.language),
          emit_line("@", target.journal_issn),
          options[:include_abstracts] && target.abstracts ? target.abstracts.map{|ab| emit_line("X", ab)} : nil,
          emit_line("1", target.notes),
          "\n"
        ].flatten.join
      end
      
      class << self
        def get_date_array(article)
          date_line = article['8'] || article['D']
          date_line.split(/[\/\s-]/)[0..2] if date_line
        end

        def get_authors(article)
          %w(A E Y ?)
          .map{|k| article[k] || []}  # could return arrays or strings
          .flatten
          .map{|a| a.split(/\s*;\s*|\s*and\s*/)} # split on ; or and
          .flatten
        end

        def emit_line(key, value)
          "%#{key} #{value}\n" unless value.nil? || value.to_s.strip == ''
        end

      end # class methods

    end # class
  end # module
end # module
