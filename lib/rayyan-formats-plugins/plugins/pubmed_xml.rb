module RayyanFormats
  module Plugins
    class PubmedXML < Base
      
      title 'PubMed XML'
      extension 'xml'
      description 'PubMed XML format'

      detect do |first_line, lines|
        first_line.start_with?('<?xml')
      end

      parse do |body, filename, &block|
        total = PubMedScraper.new([[]]).parse_search_results(body) do |mArticle, is_new, total|
          block.call(mArticle, total, is_new)
        end
        raise "Invalid XML, please follow the PubMed guide to export valid PubMed XML files" if total.nil? || total == 0
      end
      
    end # class
  end # module
end # module
