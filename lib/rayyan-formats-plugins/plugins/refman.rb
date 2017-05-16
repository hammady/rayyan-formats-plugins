require 'ref_parsers'

module RayyanFormats
  module Plugins
    class Refman < RayyanFormats::Base
      
      title 'RefMan'
      extension 'ris'
      description 'Supports journal article entries, full documentation here: http://en.wikipedia.org/wiki/RIS_(file_format)'

      KW_REGEX = /#{::RefParsers::NEWLINE_MERGER}|--|;/

      detect do |first_line, lines|
        first_line.start_with?('TY  - ')
      end

      do_import do |body, filename, &block|
        articles = ::RefParsers::RISParser.new.parse(body)
        total = articles.length

        # .select{|entry|
        #   %w(JOUR ABST ELEC THES EJOUR).include?(entry['type'])
        # }

        articles.each do |article|
          target = Target.new
          target.publication_types = get_publication_types article['type']
          target.sid = article['AN'].to_s
          target.title = article['T1'] || article['TI'] || article['CT'] || article['BT']
          target.date_array = get_date_array article
          target.journal_title = article['T2'] || article['JO'] || article['JF'] || article['J2']
          target.journal_issn = article['SN']
          target.journal_abbreviation = article['JA'] || article['J1'] || article['J2']          
          target.jvolume = article['VL'].to_i rescue 0
          target.jissue = (article['IS'] || article['M1']).to_i rescue 0
          target.pagination = "#{article['SP']}#{article['EP'] ? '-' + article['EP'] : ''}"
          target.authors = %w(AU A1 A2 A3 A4).map{|k| article[k] || []}.flatten
          target.affiliation = article['AV']
          target.url = article['UR']
          target.language = article['LA']
          target.publisher_name = article['PB']
          target.publisher_location = "#{article['AD']} #{article['CY']}".strip
          target.collection = article['T3']
          target.keywords = get_keywords article['KW']
          target.abstracts = [article['AB'], article['N2']].compact.flatten
          target.notes = try_join_arr article['N1']

          block.call(target, total)
        end
      end

      do_export do |target, options|
        [
          emit_line("TY", target.publication_types && target.publication_types.first ? set_publication_type(target.publication_types.first) : 'JOUR'),
          emit_line("AN", target.sid),
          emit_line("TI", target.title),
          target.date_array ? target.date_array.map.with_index{|y, i| emit_line("Y#{i+1}", y)} : nil,
          emit_line("T2", target.journal_title),
          emit_line("SN", target.journal_issn),
          emit_line("J2", target.journal_abbreviation),
          target.jvolume && target.jvolume > 0 ? emit_line("VL", target.jvolume) : nil,
          target.jissue && target.jissue > 0 ? emit_line("IS", target.jissue) : nil,
          emit_line("SP", target.pagination),
          target.authors ? target.authors.map{|author| emit_line("AU", author)} : nil,
          emit_line("AV", target.affiliation),
          emit_line("UR", target.url),
          emit_line("LA", target.language),
          emit_line("PB", target.publisher_name),
          emit_line("CY", target.publisher_location),
          emit_line("T3", target.collection),
          target.keywords ? target.keywords.map{|kw| emit_line("KW", kw)} : nil,
          get_abstracts(target, options){|abstracts| abstracts.map{|ab| emit_line("AB", ab)}},
          emit_line("N1", target.notes),
          "ER  -\n\n"
        ].flatten.join if target
      end

      class << self
        def get_date_array(article)
          date_line = article['PY']
          date_line = ("#{article['Y1']} #{article['Y2']} #{article['Y3']}").strip if date_line.nil?
          date_line = article['DA'] if date_line == ""
          date_line.split(/[\/\s-]/)[0..2] if date_line
        end

        def get_publication_types(pubtype)
          [
            case pubtype
            when 'JOUR', 'ELEC', 'ABST', 'EJOUR'
              "Journal Article"
            when 'THES'
              "Thesis"
            else
              pubtype
            end
          ]
        end

        def set_publication_type(pubtype)
          case pubtype
          when "Journal Article"
            'JOUR'
          when "Thesis"
            'THES'
          else
            pubtype
          end
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
          "#{key}  - #{value}\n" unless value.nil? || value.to_s.strip == ''
        end
      end # class methods

    end # class
  end # module
end # module
