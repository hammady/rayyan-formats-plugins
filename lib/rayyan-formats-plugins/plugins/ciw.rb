require 'ref_parsers'


module RayyanFormats
  module Plugins
    class CIW < RayyanFormats::Base
      
      title 'CIW'
      extension 'ciw'
      description "The ISI/Web of Science data exchange format is used by Thomson's Web of Science export function. We have not been able to find an official definition, but have used information from the Ruby Forge web site instead.'"

      KW_REGEX = /#{::RefParsers::NEWLINE_MERGER}|--|;/

      detect do |first_line, lines|
        first_line.start_with?('FN')
      end

      do_import do |body, filename, &block|
        articles = ::RefParsers::CIWParser.new.parse(body)
        total = articles.length

        articles.each do |article|
          target = Target.new
          target.sid = article['AR']|| article['AP'].to_s
          target.title = article['TI']
		  target.date_array = get_date_array article
          target.jvolume = article['VL'].to_i rescue 0
          target.pagination = "#{article['BP']}#{article['EP'] ? '-' + article['EP'] : ''}"
          target.authors = %w(AU AF CA).map{|k| article[k] || []}.flatten
          target.abstracts =article['AB']
		  target.publication_types = get_publication_types article['PT']
		  target.keywords = get_keywords article['ID']
          target.jissue = (article['IS'] || article['SI']).to_i rescue 0
          target.url = article['UR']
          target.publisher_name = article['PU']
          target.publisher_location =article['PA']
          target.language = article['LA']
          target.journal_title = article['SO']|| article['SE']
          target.journal_abbreviation = article['JI'] ||article['J9']
          target.journal_issn = article['SN']
		  target.Conference_location = article['CL']
		  target.Conference_title = article['CT']
		  target.Conference_Date = article['CY']
		  target.Research_field = article['WC']
		  target.Document_type = article['DT']
		  target.Research_addresses = article['C1']
		  target.Funding_text = article['FX']
		  target.Cited_references= article['CR']
          target.Cited_reference_count= article['NR']
		  target.ISI_unique_article_identifier= article['UT']
          block.call(target, total)
        end  
      end

      class << self
        def get_date_array(article)
          date_line = ("#{article['PY']} #{article['PD']}").strip if date_line.nil?
          #date_line = article['CY'] if date_line == ""
          date_line.split(/[\/\s-]/)[0..2] if date_line
        end
      def get_keywords(keywords)
          [keywords || []]
          .flatten
          .map {|id|
            id
            .split(KW_REGEX)
            .map(&:strip)
            .reject{|id| id == ""}
          }.flatten
        end
		
		def get_publication_types(publication_types)
          [
		    case publication_types
            when 'J'
              "Journal Article"
            when 'S'
              "Conference Proceedings"
            else
              pubtype
            end
          ]
        end
		
      end # class methods
       
     

    end # class
  end # module
end # module
