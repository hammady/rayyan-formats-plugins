require 'ref_parsers'

module RayyanFormats
  module Plugins
    class CIW < RayyanFormats::Base
      
      title 'CIW'
      extension 'ciw'
      description "The ISI/Web of Science data exchange format is used by Thomson's Web of Science export function. The informal definition is taken from the Ruby Forge web site instead."

      KW_REGEX = /#{::RefParsers::NEWLINE_MERGER}|--|;/

      detect do |first_line, lines|
        first_line.start_with?('FN')
      end

     do_import do |body, filename, &block|
        articles = ::RefParsers::CIWParser.new.parse(body)
        total = articles.length
        articles.each do |article|
          target = Target.new
          target.sid = article['UT']
          target.title = article['TI']
          target.date_array = get_date_array article	  
          target.jvolume = article['VL'].to_i rescue 0
          target.pagination = "#{article['BP']}#{article['EP'] ? '-' + article['EP'] : ''}"
          target.authors = get_authors article
          target.abstracts = get_abstrcats article
          target.publication_types = get_publication_types article['type']
          target.keywords = get_keywords article['ID']
          target.jissue = (article['IS'] || article['SI']).to_i rescue 0
          target.url = article['UR']
          target.publisher_name = article['PU']
          target.publisher_location = article['PA']
          target.language = article['LA']
          target.journal_title = article['SO'] || article['SE']
          target.journal_abbreviation = article['JI'] ||article['J9']
          target.journal_issn = article['SN']
          target.Conference_location = article['CL']
          target.Conference_title = article['CT']
          target.Conference_Date = article['CY']
          target.Research_field = article['WC']
          target.Document_type = article['DT']
          target.Research_addresses = article['C1']
          target.Funding_text = article['FX']
          target.Cited_references = article['CR']
          target.Cited_reference_count = article['NR']
          block.call(target, total)
        end
      end

      do_export do |target, options|
        [
          emit_line("FN","Thomson Reuters Web of Science"),
          emit_line("VR", "1.0"),
          emit_line("PT", target.publication_types ? set_publication_type(target.publication_types.first) : 'J'),
          emit_line("AU", target.authors.first),
          target.authors ? target.authors.map.with_index{|author, i| emit_line("  ",target.authors[i+1])} : nil,
          emit_line("TI", target.title),
          emit_line("SO", target.journal_title),
          emit_line("PD", "#{target.date_array[1]} #{target.date_array[2]}"),
          emit_line("PY", target.date_array[0]),
          emit_line("BP", target.pagination),
          options[:include_abstracts] && target.abstracts ? target.abstracts.map.with_index{|author, i| emit_line("AB",target.abstracts[i])} : nil,
          emit_line("SN", target.journal_issn),
          emit_line("DT", target.Document_type),
          emit_line("PU", target.publisher_name),
          emit_line("PA", target.publisher_location),
          emit_line("JI", target.journal_abbreviation),
          target.jvolume && target.jvolume > 0 ? emit_line("VL", target.jvolume) : nil,
          target.jissue && target.jissue > 0 ? emit_line("IS", target.jissue) : nil,
          emit_line("UR", target.url),
          emit_line("ID", "#{target.keywords.first};"),
          target.keywords ? target.keywords.map.with_index { |id, i| i+1 == target.keywords.length ? nil : emit_line("  ","#{target.keywords[i+1]};") }: nil,
          emit_line("LA", target.language),
          emit_line("UT", target.sid),  
          "ER\n\nEF"	
        ].flatten.join if target
      end
	 
      class << self
	      def get_date_array(article)
	        day = ("#{article['PD']}")
		      t=day.split(/\s+/)
		      p=set_convert_date t[0]
          date_line = ("#{article['PY']} #{p} #{t[1]}")
		      date_line.split(/[\/\s-]/)[0..2] if date_line
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

	      MONTHS = %w(dummy JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC)

        def set_convert_date(month)
         month = MONTHS.index(month) unless month.nil?
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

	  	  def get_abstrcats(article)
          %w(AB)
          .map{|k| article[k] || []}  # could return arrays or strings
          .flatten
        end
		
        def get_authors(article)
          %w(AU AF CA)
          .map{|k| article[k] || []}  # could return arrays or strings
          .flatten
          .map{|a| a.split(/#{::RefParsers::NEWLINE_MERGER}\s+/)}
          .flatten
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
