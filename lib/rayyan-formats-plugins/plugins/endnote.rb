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
          target.date_array = [article['D']]
          target.jvolume = article['V'].to_i rescue 0
          target.pagination = article['P']
          target.authors = get_authors article
          target.abstracts = [article['X']].compact
          target.jissue = (article['N'] || article['N']).to_i rescue 0
          target.url = article['U'] || article['>']
          target.publication_types = get_publication_types article
          target.publisher_name = article['I']
          target.publisher_location = article['C']
          target.journal_title = article['J'] || article['B']
          target.journal_issn = article['@']
          target.language = article['G']
          target.notes = try_join_arr article['1']

          block.call(target, total)
        end
      end
      
      class << self
        def get_authors(article)
          %w(A E Y ?)
          .map{|k| article[k] || []}  # could return arrays or strings
          .flatten
          .map{|a| a.split(/\s*;\s*|\s*and\s*/)} # split on ; or and
          .flatten
        end

        def get_publication_types(article)
          [article['type'] == 'Journal Article' ? 'Journal Article' : article['type']]
        end

      end # class methods

    end # class
  end # module
end # module
