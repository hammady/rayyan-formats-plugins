require 'ref_parsers'

module RayyanFormats
  module Plugins
    class EndNote < RayyanFormats::Base
      
      title 'EndNote'
      extension 'enw'
      description 'Supports entries of type Journal Article, full documentation here: http://www.harzing.com/pophelp/exporting.htm#endnote and here: http://wiki.cns.iu.edu/pages/viewpage.action?pageId=1933370'

      KW_REGEX = /#{::RefParsers::NEWLINE_MERGER}|--|;/

      detect do |first_line, lines|
        first_line.start_with?('%0')
      end

      do_import do |body, filename, &block|
        articles = ::RefParsers::EndNoteParser.new.parse(body)
        total = articles.length

        # articles.select{|entry| entry['type'] == 'Journal Article'}.each do |article|
        articles.each do |article|
          target = Target.new
          target.publication_types = [article['type']]
          target.sid = article['M']
          target.title = article['T']
          target.date_array = get_date_array article
          target.journal_title = article['J'] || article['B']
          target.journal_issn = article['@']
          target.jvolume = article['V'].to_i rescue 0
          target.jissue = article['N'].to_i rescue 0
          target.pagination = article['P']
          target.authors = get_authors article
          target.affiliation = article['+']
          target.url = article['U'] || article['>']
          target.language = article['G']
          target.publisher_name = article['I']
          target.publisher_location = article['C']
          # TODO collection
          target.keywords = get_keywords article['K']
          target.abstracts = [article['X']].flatten.compact
          target.notes = try_join_arr article['1']

          block.call(target, total)
        end
      end

      do_export do |target, options|
        [
          emit_line("0", target.publication_types && target.publication_types.first ? target.publication_types.first : 'Journal Article'),
          emit_line("M", target.sid),
          emit_line("T", target.title),
          target.date_array ? emit_line("D", target.date_array.first) : nil,
          target.date_array ? emit_line("8", target.date_array.join("-")) : nil,
          emit_line("J", target.journal_title),
          emit_line("@", target.journal_issn),
          target.jvolume && target.jvolume > 0 ? emit_line("V", target.jvolume) : nil,
          target.jissue && target.jissue > 0 ? emit_line("N", target.jissue) : nil,
          emit_line("P", target.pagination),
          target.authors ? target.authors.map{|author| emit_line("A", author)} : nil,
          emit_line("+", target.affiliation),
          emit_line("U", target.url),
          emit_line("G", target.language),
          emit_line("I", target.publisher_name),
          emit_line("C", target.publisher_location),
          # TODO collection
          target.keywords ? target.keywords.map{|kw| emit_line("K", kw)} : nil,
          get_abstracts(target, options){|abstracts| abstracts.map{|ab| emit_line("X", ab)}},
          emit_line("1", target.notes),
          "\n"
        ].flatten.join if target
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

        def get_keywords(keywords)
          [keywords || []]
          .flatten
          .map {|kw|
            kw
            .split(KW_REGEX)
            .map(&:strip)
            .reject{|kw| kw == ""}
          }.flatten
        end

        def emit_line(key, value)
          "%#{key} #{value}\n" unless value.nil? || value.to_s.strip == ''
        end

      end # class methods

    end # class
  end # module
end # module
