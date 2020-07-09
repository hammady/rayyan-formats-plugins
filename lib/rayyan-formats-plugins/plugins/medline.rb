require 'ref_parsers'

module RayyanFormats
  module Plugins
    class MEDLINE < RayyanFormats::Base
      title 'MEDLINE'
      extension 'nbib'
      description 'Supports the Pubmed MEDLINE format as outlined here: https://www.nlm.nih.gov/bsd/mms/medlineelements.html'

      detect do |first_line, _|
        first_line.start_with?('PMID')
      end

      do_import do |body, _, &block|
        articles = ::RefParsers::PubMedParser.new.parse(body)
        total = articles.length

        articles.each do |article|
          target = Target.new
          # Convert PT to Array in case only one PT
          target.publication_types = Array(article['PT'])
          # Accession number is the first line and hence is in article['type]
          target.sid = article['type']
          target.title = article['TI']&.gsub(/\s+/, ' ')
          target.date_array = get_date_array article['DP']
          target.journal_title = article['JT']
          target.journal_issn = get_issn article['IS']
          target.journal_abbreviation = article['TA']
          # to_i grabs the first integer it sees, so '5 Spec No' becomes 5
          target.jvolume = article['VI']&.to_i
          target.jissue = article['IP']&.to_i
          target.pagination = article['PG']
          target.authors = Array(article['AU'])
          target.affiliation = get_multivalued_field_with_newline_merger(article['AD']).join('; ') if article['AD']
          # Generates url from pmid stored in article['type']
          target.url = get_pubmed_url article['type']
          target.language = article['LA']
          target.publisher_location = article['PL']
          target.collection = article['CTI']
          target.keywords = Array(article['MH'])
          target.abstracts = get_multivalued_field_with_newline_merger article['AB']
          target.notes = article['GN']
          target.article_ids = get_article_ids article
          target.copyright = article['CI']

          block.call(target, total)
        end
      end

      do_export do |target, options|
        [
          "PMID- #{target.sid}\n",
          emit_lines_from_array('PT', target.publication_types),
          emit_line('TI', target.title),
          emit_line('DP', format_date_array(target.date_array)),
          emit_line('JT', target.journal_title),
          emit_line('IS', target.journal_issn),
          emit_line('TA', target.journal_abbreviation),
          emit_line('VI', target.jvolume),
          emit_line('IP', target.jissue),
          emit_line('PG', target.pagination),
          emit_lines_from_array('AU', target.authors),
          emit_lines_from_array('AD', target.affiliation),
          emit_lines_from_array('LA', target.language),
          emit_line('PL', target.publisher_location),
          emit_line('CTI', target.collection),
          emit_lines_from_array('MH', target.keywords),
          get_abstracts(target, options) { |abstracts| emit_lines_from_array('AB', abstracts) },
          emit_lines_from_array('GN', target.notes),
          emit_article_id('PMC', :pmc_id, target.article_ids),
          emit_article_id('AID', :doi, target.article_ids),
          emit_article_id('AID', :pii, target.article_ids),
          "\n"
        ].flatten.join if target
      end

      class << self
        def get_date_array(date_line)
          # Converts MEDLINE date format to date array
          # Example dates in the MEDLINE format:
          # 2001 Apr 15
          # 2001 Apr
          # 2000 Spring
          # 2000 Nov-Dec
          # 2001
          return unless date_line

          splitted_date_line = date_line.split(' ')

          year = splitted_date_line[0]
          month = (convert_abbr_month_name_to_number splitted_date_line[1])&.to_s
          day = splitted_date_line[2]

          return [] if year.nil?
          return [year] if month.nil?
          return [year, month] if day.nil?

          [year, month, day]
        end

        def convert_abbr_month_name_to_number(month_name)
          # Converts abbreviated month names to month number
          return unless month_name

          month_name_to_convert = month_name
          # Check if month name is something like Nov-Dec
          month_name_to_convert = month_name_to_convert.split('-')[0] if month_name_to_convert.include? '-'
          month_number = Date::ABBR_MONTHNAMES.index(month_name_to_convert)

          month_number unless month_number.nil?
        end

        def get_pubmed_url(pmid)
          return unless pmid

          "https://pubmed.ncbi.nlm.nih.gov/#{pmid}/"
        end

        def get_article_ids(article)
          article_ids = []
          article_ids.push( idtype: :pubmed_id, value: article['type'] ) if article['type']
          article_ids.push(idtype: :pmc_id, value: article['PMC']) if article['PMC']
          return article_ids unless article['AID']

          # A single AID line is parsed as a string, turn it into an array
          # Multiple AID lines are also possible
          aid_lines = [article['AID']].flatten

          aid_lines.each do |line|
            article_ids.push(idtype: :doi, value: line) if line.include? 'doi'
            article_ids.push(idtype: :pii, value: line) if line.include? 'pii'
          end

          article_ids
        end

        def get_issn(issn)
          # MEDLINE returns multiple ISSN, return the first one
          return unless issn

          issn.is_a?(Array) ? issn[0] : issn
        end

        def get_multivalued_field_with_newline_merger(values)
          return [] unless values

          # If single-valued string field, convert to array
          values_to_get = Array(values)

          # Get rid of extra spaces created by newline merger
          values_to_get.map! do |value|
            value.gsub(/\s+/, ' ')
          end
        end

        def format_date_array(date_array)
          # Converts date array to MEDLINE date format
          # Eg date_array = ["2017", "10", "1"]
          year = date_array[0]
          month = Date::ABBR_MONTHNAMES[date_array[1].to_i] if date_array[1]
          day = date_array[2]

          return '' if year.nil?
          return "#{year}" if month.nil?
          return "#{year} #{month}" if day.nil?

          "#{year} #{month} #{day}"
        end

        def emit_line(key, value)
          # Pad key to 4 characters to match nbib
          padded_key = format('%-4.4s', key)
          "#{padded_key}- #{value}\n" unless value.nil? || value.to_s.strip.empty?
        end

        def emit_lines_from_array(key, values_arr)
          return unless values_arr

          Array(values_arr).map { |val| emit_line(key, val) }
        end

        def emit_article_id(key, article_id_type, article_ids)
          return unless article_ids

          aid_obj_to_emit = article_ids.detect { |aid_obj| aid_obj[:idtype] == article_id_type }
          emit_line(key, aid_obj_to_emit[:value]) if aid_obj_to_emit
        end
      end
    end
  end
end
