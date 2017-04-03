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
        # TODO: FILTER ONLY @articles?
        b['@article'].each do |article|
          target = Target.new
          target.sid = to_s_or_nil article['key']
          target.title = article['title'].to_s
          target.date_array = [article['year'], article['month']].compact.map(&:to_s)
          target.jvolume = article['volume'].to_i rescue 0
          target.pagination = to_s_or_nil article['pages']
          target.authors = article[:author].split(/\s*;\s*|\s*and\s*/) if article[:author]
          target.affiliation = to_s_or_nil article['institution']
          target.publication_types = [to_s_or_nil(article['type'])].compact
          target.jissue = article['number'].to_i rescue 0
          target.url = to_s_or_nil article['url']
          target.collection = to_s_or_nil article['series']
          target.publisher_name = to_s_or_nil article['publisher']
          target.publisher_location = to_s_or_nil article['address']
          target.journal_title = to_s_or_nil article['journal']
          target.abstracts = [to_s_or_nil(article['abstract'])].compact

          block.call(target, total)
        end  
      end

      class << self
        def to_s_or_nil(value)
          value.to_s unless value.nil?
        end
      end # class methods

    end # class
  end # module
end # module
