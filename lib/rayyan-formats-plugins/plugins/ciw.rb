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
          target.pagination = get_pagination article
          target.authors = get_authors article
          target.abstracts =article['AB']
		      target.publication_types = get_publication_types article['type']
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
    do_export do |target, options|
        [
		   emit_line("FN","Thomson Reuters Web of Science"),
		   emit_line("VR", "1.0"),
       emit_line("PT", target.publication_types ? set_publication_type(target.publication_types.first) : 'J'),
		   target.authors ? emit_line("AU", target.authors.first): nil,
		   target.authors ? emit_line("  ", target.authors.last): nil,
       emit_line("TI", target.title),
		   emit_line("SO", target.journal_title),
		   target.date_array ?  emit_line("PD", target.date_array.last): nil,
       target.date_array ?  emit_line("PY", target.date_array.first) : nil,
       target.pagination ?  emit_line("BP", target.pagination.first) : nil,
		   target.pagination ?  emit_line("EP", target.pagination.last) : nil,
		   options[:include_abstracts] && target.abstracts ? emit_line("AB", target.abstracts): nil,
		   emit_line("SN", target.journal_issn),
		   emit_line("DT", target.Document_type),
       emit_line("PU", target.publisher_name),
		   emit_line("PA", target.publisher_location),
       emit_line("JI", target.journal_abbreviation),
       target.jvolume && target.jvolume > 0 ? emit_line("VL", target.jvolume) : nil,
       target.jissue && target.jissue > 0 ? emit_line("IS", target.jissue) : nil,
       emit_line("UR", target.url),
       emit_line("LA", target.language),
       "ER\n\nEF"	
        ].flatten.join if target
    end
	 
    class << self
	    def get_pagination(article)
		 pagination_pages = ("#{article['BP']} #{article['EP']}").strip if pagination_pages.nil?
		 
         pagination_pages.split(/[\-]/) if pagination_pages
      end
		
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
            .split(/[\;]/)
            .map(&:strip)
            .reject{|id| id == ""}
          }.flatten
      end
		
      def get_authors(article)
          %w(AU AF CA)
          .map{|k| article[k] || []}  # could return arrays or strings
          .flatten
          .map{|a| a.split(::RefParsers::NEWLINE_MERGER)}
          .flatten
      end

		  def get_publication_types(publication_types)
          [
		    case publication_types
            when 'J'
              "Journal Article"
            when 'S'
              "Conference Proceedings"
            else
              publication_types
            end
          ]
        end
						 
        def set_publication_type(publication_types)
          case publication_types
          when "Journal Article"
            'J'
          when "Conference Proceedings"
            'S'
          else
            publication_types
          end
        end
		
		    def emit_line(key, value)
          "#{key} #{value}\n" unless value.nil? || value.to_s.strip == ''
        end
      end # class methods
    end # class
  end # module
end # module
