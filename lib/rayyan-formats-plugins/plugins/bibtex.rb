# http://en.wikipedia.org/wiki/BibTeX
# http://www.cs.arizona.edu/~collberg/Teaching/07.231/BibTeX/bibtex.html
module RayyanFormats
  module Plugins
    class BibTeX < Base
      
      title 'BibTeX'
      extension 'bib'
      description 'Supports entries of type article, full documentation here: http://en.wikipedia.org/wiki/BibTeX'

      detect do |first_line, lines|
        first_line.start_with?('@article')
      end

      parse do |body, filename, &block|
        b = ::BibTeX.parse(body)
        total = b.length
        # TODO: FILTER ONLY @articles?
        b['@article'].each do |article|
          mArticle = Article.new
          mArticle.title = article['title'].to_s
          mArticle.jcreated_at = ScraperBase.to_date article['year'], article['month']
          mArticle.jvolume = article['volume'].to_i rescue 0
          mArticle.pagination = article['pages'].to_s
          mArticle.sid = article['key'].to_s

          mArticle.insert_ordered_authors(article['author'])

          mArticle.affiliation = article['institution'].to_s

          mArticle.publication_types << PublicationType.where(name: article['type'].to_s).first_or_initialize unless article['type'].blank?

          mArticle.jissue = article['number'].to_i rescue 0
          mArticle.url = article['url'].to_s
          mArticle.collection = Collection.where(name:article['series'].to_s).first_or_initialize unless article['series'].blank?

          mArticle.publisher = Publisher.where(name: article['publisher'].to_s).first_or_initialize {|p|
            p.location = article['address'].to_s
          } unless article['publisher'].blank?
          mArticle.journal = Journal.where(title: article['journal'].to_s).first_or_create unless article['journal'].blank?

          mArticle.abstracts.build content: article['abstract'].to_s unless article['abstract'].blank?

          block.call(mArticle, total)
        end  
      end

    end # class
  end # module
end # module
