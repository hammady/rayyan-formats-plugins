module RayyanFormats
  module Plugins
    class Refman < RayyanFormats::Base
      
      title 'RefMan'
      extension 'ris'
      description 'Supports entries of type JOUR, full documentation here: http://en.wikipedia.org/wiki/RIS_(file_format)'

      detect do |first_line, lines|
        first_line.start_with?('TY  - ')
      end

      parse do |body, filename, &block|
        articles = RefParsers::RISParser.new.parse(body)
        total = articles.length

        pubtype_journal = PublicationType.where(name: "Journal Article").first_or_initialize
        pubtype_thesis = PublicationType.where(name: "Thesis").first_or_initialize
        kw_regex = /#{RefParsers::NEWLINE_MERGER}|--|;/

        # .select{|entry|
        #   %w(JOUR ABST ELEC THES EJOUR).include?(entry['type'])
        # }

        articles.each do |article|
          mArticle = Article.new
          mArticle.title = article['T1'] || article['TI'] || article['CT'] || article['BT']
          date_line = article['PY'] || ("#{article['Y1']} #{article['Y2']} #{article['Y3']}") || article['DA']
          mArticle.jcreated_at = ScraperBase.to_date *(date_line.split(/[\/\s-]/)[0..2]) if date_line.present?
          mArticle.jvolume = article['VL'].to_i rescue 0
          mArticle.pagination = "#{article['SP']}#{article['EP'] ? '-' + article['EP'] : ''}"
          mArticle.sid = article['AN'].to_s

          mArticle.insert_ordered_authors(%w(AU A1 A2 A3 A4).map{|k| article[k] || []}.flatten)

          mArticle.abstracts.build content: article['AB'] if article['AB']
          mArticle.abstracts.build content: article['N2'] if article['N2']

          case article['type']
          when 'JOUR', 'ELEC', 'ABST', 'EJOUR'
            mArticle.publication_types << pubtype_journal
          when 'THES'
            mArticle.publication_types << pubtype_thesis
          else
            mArticle.publication_types << PublicationType.where(name: article['type']).first_or_initialize
          end

          [article['KW'] || []].flatten.each do |kw|
            kw.split(kw_regex).reject{|kw|kw.blank?}.map(&:strip).each{|kw| mArticle.keyphrases << Keyphrase.where(name: kw).first_or_initialize}
          end

          mArticle.jissue = (article['IS'] || article['M1']).to_i rescue 0
          mArticle.url = article['UR']
          mArticle.collection = Collection.where(title: article['T3']).first_or_initialize unless article['T3'].blank?

          mArticle.publisher = Publisher.where(name: article['PB']).first_or_initialize {|p|
            p.location = "#{article['AD']} #{article['CY']}"
          } unless article['PB'].blank?

          journal = article['T2'] || article['JO'] || article['JF'] || article['J2']
          mArticle.journal = Journal.where(title: journal).first_or_create {|j|
            j.abbreviation = article['JA'] || article['J1'] || article['J2']
            j.issn = article['SN']
          } unless journal.blank?

          mArticle.language = article['LA']
          mArticle.affiliation = article['AV'] if article['AV']
          mArticle.notes = get_notes(article['N1'])

          block.call(mArticle, total)
        end  
      end
      
    end # class
  end # module
end # module
