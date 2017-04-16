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
          target.sid = article['AN'].to_s
          target.title = article['T1'] || article['TI'] || article['CT'] || article['BT']
          target.date_array = get_date_array article
          target.jvolume = article['VL'].to_i rescue 0
          target.pagination = "#{article['SP']}#{article['EP'] ? '-' + article['EP'] : ''}"
          target.authors = %w(AU A1 A2 A3 A4).map{|k| article[k] || []}.flatten
          target.abstracts = [article['AB'], article['N2']].compact.flatten
          target.publication_types = get_publication_types article['type']
          target.keywords = get_keywords article['KW']
          target.jissue = (article['IS'] || article['M1']).to_i rescue 0
          target.url = article['UR']
          target.publisher_name = article['PB']
          target.publisher_location = "#{article['AD']} #{article['CY']}".strip
          target.language = article['LA']
          target.journal_title = article['T2'] || article['JO'] || article['JF'] || article['J2']
          target.journal_abbreviation = article['JA'] || article['J1'] || article['J2']
          target.journal_issn = article['SN']
          target.notes = try_join_arr article['N1']
          target.collection = article['T3']
          target.affiliation = article['AV']

          block.call(target, total)
        end  
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
      end # class methods

    end # class
  end # module
end # module
