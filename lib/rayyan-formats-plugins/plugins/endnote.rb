module RayyanFormats
  module Plugins
    class EndNote < RayyanFormats::Base
      
      title 'EndNote'
      extension 'enw'
      description 'Supports entries of type Journal Article, full documentation here: http://www.harzing.com/pophelp/exporting.htm#endnote and here: http://wiki.cns.iu.edu/pages/viewpage.action?pageId=1933370'

      detect do |first_line, lines|
        first_line.start_with?('%0')
      end

      parse do |body, filename, &block|
        articles = RefParsers::EndNoteParser.new.parse(body)
        total = articles.length
        pubtype_journal = PublicationType.where(name: "Journal Article").first_or_initialize

        # articles.select{|entry| entry['type'] == 'Journal Article'}.each do |article|
        articles.each do |article|
          mArticle = Article.new
          mArticle.title = article['T']
          mArticle.jcreated_at = ScraperBase.to_date article['D']
          mArticle.jvolume = article['V'].to_i rescue 0
          mArticle.pagination = article['P']

          mArticle.insert_ordered_authors(
            %w(A E Y ?)
            .map{|k| article[k] || []}  # could return arrays or strings
            .flatten
            .map{|a| a.split(/\s*;\s*|\s*and\s*/)} # split on ; or and
            .flatten
          )

          mArticle.abstracts.build content: article['X'] if article['X']

          case article['type']
          when 'Journal Article'
            mArticle.publication_types << pubtype_journal
          else
            mArticle.publication_types << PublicationType.where(name: article['type']).first_or_initialize
          end

          mArticle.jissue = (article['N'] || article['N']).to_i rescue 0
          mArticle.url = article['U'] || article['>']

          mArticle.publisher = Publisher.where(name: article['I']).first_or_initialize {|p|
            p.location = article['C']
          } unless article['I'].blank?

          journal = article['J'] || article['B']
          mArticle.journal = Journal.where(title: journal).first_or_create {|j|
            j.issn = article['@']
          } unless journal.blank?

          mArticle.language = article['G']
          mArticle.notes = get_notes(article['1'])

          block.call(mArticle, total)
        end
      end
      
    end # class
  end # module
end # module
