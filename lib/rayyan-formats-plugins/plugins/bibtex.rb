require 'bibtex'

# http://en.wikipedia.org/wiki/BibTeX
# http://www.cs.arizona.edu/~collberg/Teaching/07.231/BibTeX/bibtex.html
module RayyanFormats
  module Plugins
    class BibTeX < RayyanFormats::Base
      
      title 'BibTeX'
      extension 'bib'
      description 'Supports entries of type article, full documentation here: http://en.wikipedia.org/wiki/BibTeX'

      detect do |first_line, lines|
        first_line.start_with?('@article')
      end

      do_import do |body, filename, &block|
        b = ::BibTeX.parse(body)
        total = b.length
        b.each do |article|
          target = Target.new
          target.publication_types = get_pub_types(article)
          target.sid = to_s_or_nil article.key
          target.title = get_title(article)
          target.date_array = convert_date article['year'], article['month']
          target.journal_title = to_s_or_nil article['journal']
          target.journal_issn = to_s_or_nil article['issn']
          target.jvolume = article['volume'].to_i rescue 0
          target.jissue = article['number'].to_i rescue 0
          target.pagination = to_s_or_nil article['pages']
          target.authors = get_authors(article)
          target.affiliation = to_s_or_nil(article['institution']) || to_s_or_nil(article['school'])
          target.url = to_s_or_nil article['url']
          target.language = to_s_or_nil article['language']
          target.publisher_name = to_s_or_nil article['publisher']
          target.publisher_location = to_s_or_nil article['address']
          target.collection = to_s_or_nil article['series']
          target.keywords = to_arr_or_nil article['keywords']
          target.abstracts = [to_s_or_nil(article['abstract'])].compact
          target.notes = to_s_or_nil article['note']

          block.call(target, total)
        end  
      end

      do_export do |target, options|
        "@article{#{get_unique_id(target, options)},\n" + [
          emit_line("title", target.title),
          target.date_array && target.date_array[0] ? emit_line("year", target.date_array[0]) : nil,
          target.date_array && target.date_array[1] ? emit_line("month", target.date_array[1]) : nil,
          emit_line("journal", target.journal_title),
          emit_line("issn", target.journal_issn),
          target.jvolume && target.jvolume > 0 ? emit_line("volume", target.jvolume) : nil,
          target.jissue && target.jissue > 0 ? emit_line("number", target.jissue) : nil,
          emit_line("pages", target.pagination),
          target.authors ? emit_line("author", target.authors.join(' and ')) : nil,
          emit_line("institution", target.affiliation),
          emit_line("url", target.url),
          emit_line("language", target.language),
          emit_line("publisher", target.publisher_name),
          emit_line("address", target.publisher_location),
          emit_line("series", target.collection),
          target.keywords ? emit_line("keywords", target.keywords.join(', ')) : nil,
          get_abstracts(target, options){|abstracts| emit_line("abstract", abstracts.join("\n").strip)},
          emit_line("note", target.notes)
        ].compact.join(",\n") + "\n}\n\n" if target
      end

      class << self
        def to_s_or_nil(value)
          value.to_s unless value.nil?
        end

        def to_arr_or_nil(value)
          value.to_s.split(/\s*,\s*/) unless value.nil?
        end

        MONTHS = %w(dummy jan feb mar apr may jun jul aug sep oct nov dec)

        def convert_date(year, month)
          month = MONTHS.index(month) unless month.nil?
          [year, month].compact.map(&:to_s)
        end

        def emit_line(key, value)
          "  #{key}={#{value}}" unless value.nil? || value.to_s.strip == ''
        end

        def get_unique_id(target, options)
          if target.sid && target.sid.to_s.strip != ''
            target.sid
          else
            options[:unique_id]
          end
        end

        def get_pub_types(article)
          [
            case article.type
            when :article
              'Journal Article'
            when :proceedings, :inproceedings
              'Conference Article'
            when :book, :booklet, :inbook, :incollection
              'Book'
            else
              article.type.to_s
            end
          ]
        end

        def get_title(article)
          title = article['title'].to_s
          title = "#{title} - #{article['booktitle']}" if article['booktitle']
          title
        end

        def get_authors(article)
          value = article['author'] || article['editor']
          value.split(/\s*;\s*|\s*and\s*/) if value
        end

      end # class methods

    end # class
  end # module
end # module
