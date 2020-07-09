require 'spec_helper'

include RayyanFormats::Plugins

describe MEDLINE do
  describe '.detect' do
    it 'returns false if file does not start with PMID line' do
      expect(MEDLINE.send(:detect, '1234', [])).to eq(false)
    end

    it 'returns true if file starts with PMID line' do
      expect(MEDLINE.send(:detect, 'PMID- 287654', [])).to eq(true)
    end
  end

  describe '.do_import' do
    let(:filename) { 'spec/support/example1.nbib' }
    let(:body) { File.read(filename, mode: 'r:bom|UTF-8') }
    let(:expected_total) { 10 }
    let(:plugin) { MEDLINE }

    it_behaves_like 'repetitive target yielder'

    it 'assigns correct values' do
      line = 0
      MEDLINE.send(:do_import, body, filename) do |target|
        case line
        when 0
          expect(target.publication_types).to eq(['Journal Article', 'Review'])
          expect(target.sid).to eq('29952495')
          expect(target.title).to eq('Breast cancer: basics, screening, diagnostics and treatment.')
          expect(target.date_array).to eq(%w[2017 2])
          expect(target.journal_title).to eq('Medizinische Monatsschrift fur Pharmazeuten')
          expect(target.journal_issn).to eq('0342-9601 (Print)')
          expect(target.journal_abbreviation).to eq('Med Monatsschr Pharm')
          expect(target.jvolume).to eq(40)
          expect(target.jissue).to eq(2)
          expect(target.pagination).to eq('55-64')
          expect(target.authors).to eq(['Wörmann B'])
          expect(target.affiliation).to eq('Medizinische Klinik mit Schwerpunkt Hämatologie')
          expect(target.url).to eq('https://pubmed.ncbi.nlm.nih.gov/29952495/')
          expect(target.language).to eq(%w[eng ger])
          expect(target.publisher_location).to eq('Germany')
          expect(target.collection).to eq('Breast Cancer Reviews')
          expect(target.keywords).to eq(['Combined Modality Therapy', 'Early Detection of Cancer', 'Female', 'Humans', 'Mass Screening'])
          expect(target.abstracts[0]).to start_with('Breast cancer is by far the most common malignancy in women. The median age is 64 years')
          expect(target.notes).to eq(['KIE: Article and commentaries', 'KIE: KIE BoB Subject Heading: health care'])
          expect(target.article_ids).to eq([idtype: :pubmed_id, value: '29952495'])
        when 1
          expect(target.publication_types).to eq(['Journal Article', 'Review'])
          expect(target.sid).to eq('28298516')
          expect(target.title).to eq('Precision Medicine in Breast Cancer.')
          expect(target.date_array).to eq(%w[2017 3])
          expect(target.journal_title).to eq('Radiologic technology')
          expect(target.journal_issn).to eq('1943-5657 (Electronic)')
          expect(target.journal_abbreviation).to eq('Radiol Technol')
          expect(target.jvolume).to eq(88)
          expect(target.jissue).to eq(4)
          expect(target.pagination).to eq('401M-421M')
          expect(target.authors).to eq(['Odle TG'])
          expect(target.affiliation).to eq(nil)
          expect(target.url).to eq('https://pubmed.ncbi.nlm.nih.gov/28298516/')
          expect(target.language).to eq('eng')
          expect(target.publisher_location).to eq('United States')
          expect(target.collection).to eq('Breast Cancer Reviews')
          expect(target.keywords).to eq(
            ['Biomarkers, Tumor', 'Breast Neoplasms/*diagnosis/*genetics/*therapy', 'Female', '*Genomics', 'Humans', '*Precision Medicine']
          )
          expect(target.abstracts[0]).to start_with(
            'Breast cancer care has improved markedly in recent decades, but new advancements in ' +
            'diagnosis and treatment depend on translating genomics and precision medicine into ' +
            'clinical care'
          )
          expect(target.notes).to eq('KIE: Article and commentaries')
          expect(target.article_ids).to eq(
            [
              { idtype: :pubmed_id, value: '28298516' },
              { idtype: :pii, value: '88/4/401M [pii]' }
            ]
          )
          expect(target.copyright).to eq('©2017 American Society of Radiologic Technologists.')
        when 2
          expect(target.publication_types).to eq(['Introductory Journal Article'])
          expect(target.sid).to eq('20521754')
          expect(target.title).to eq('Treatment of breast cancer.')
          expect(target.date_array).to eq(%w[2010 6 1])
          expect(target.journal_title).to eq('American family physician')
          expect(target.journal_issn).to eq('1532-0650 (Electronic)')
          expect(target.journal_abbreviation).to eq('Am Fam Physician')
          expect(target.jvolume).to eq(81)
          expect(target.jissue).to eq(11)
          expect(target.pagination).to eq('1339-46')
          expect(target.authors).to eq(['Maughan KL', 'Lutterbie MA', 'Ham PS'])
          expect(target.affiliation).to eq(
            'Department of Family Medicine, University of Virginia School of Medicine, ' +
            'Charlottesville, VA 22908, USA. kmaughan@virginia.edu'
          )
          expect(target.url).to eq('https://pubmed.ncbi.nlm.nih.gov/20521754/')
          expect(target.language).to eq('eng')
          expect(target.publisher_location).to eq('United States')
          expect(target.collection).to eq(nil)
          expect(target.keywords).to eq(
            ['Antineoplastic Agents/therapeutic use', 'Breast Neoplasms/drug therapy/pathology/radiotherapy/surgery/*therapy',
              'Combined Modality Therapy', 'Female', 'Humans', 'Mastectomy', 'Neoplasm Staging', 'Sentinel Lymph Node Biopsy']
          )
          expect(target.abstracts[0]).to start_with(
            'Understanding breast cancer treatment options can help family physicians care for ' +
            'their patients during and after cancer treatment. This article reviews typical'
          )
          expect(target.notes).to eq(nil)
          expect(target.article_ids).to eq(
            [
              { idtype: :pubmed_id, value: '20521754' },
              { idtype: :pii, value: 'd8230 [pii]' }
            ]
          )
        when 3
          expect(target.publication_types).to eq(['Journal Article'])
          expect(target.sid).to eq('27533387')
          expect(target.title).to eq('Title that spans multiple lines for this particular research article')
          expect(target.date_array).to eq(%w[2000 11])
          expect(target.journal_issn).to eq('2047-9018 (Electronic)')
          expect(target.authors).to eq(['Pearce L'])
          expect(target.article_ids).to eq(
            [
              { idtype: :pubmed_id, value: '27533387' },
              { idtype: :doi, value: '10.7748/ns.30.51.15.s16 [doi]' },
            ]
          )
        when 4
          expect(target.publication_types).to eq(['Journal Article', 'Review'])
          expect(target.sid).to eq('29284222')
          expect(target.date_array).to eq(%w[2017 12 23])
          expect(target.authors).to eq(
            ['Kolak A', 'Kamińska M', 'Sygit K', 'Budny A', 'Surdyka D', 'Kukiełka-Budny B', 'Burdan F']
          )
          expect(target.affiliation).to eq(
            "St. John's Cancer Center, Department of Radiotherapy, Lublin, Poland. agkola@interia.pl.; " +
            "St. John's Cancer Center, Department of Oncology, Lublin, Poland.; " +
            "University of Szczecin, Faculty of Physical Education and Health Promotion, Szczecin, Poland.; " +
            "St. John's Cancer Center, Department of Radiotherapy, Lublin, Poland.; " +
            "St. John's Cancer Center, Department of Radiotherapy, Lublin, Poland.; " +
            "St. John's Cancer Center, Department of Oncology, Lublin, Poland.; " +
            "Human Anatomy Department, Medical Univeristy of Lublin, Poland."
          )
          expect(target.article_ids).to eq(
            [
              { idtype: :pubmed_id, value: '29284222' },
              { idtype: :pii, value: '75943 [pii]' },
              { idtype: :doi, value: '10.26444/aaem/75943 [doi]' }
            ]
          )
        when 5
          expect(target.publication_types).to eq(['Journal Article', 'Review'])
          expect(target.sid).to eq('21969133')
          expect(target.date_array).to eq(%w[2011 11])
          expect(target.authors).to eq(['DeSantis C', 'Siegel R', 'Bandi P', 'Jemal A'])
          expect(target.affiliation).to eq(
            'Epidemiologist, Surveillance Research, American Cancer Society, Atlanta, GA 30303, USA. carol.desantis@cancer.org'
          )
          expect(target.article_ids).to eq(
            [
              { idtype: :pubmed_id, value: '21969133' },
              { idtype: :doi, value: '10.3322/caac.20134 [doi]' }
            ]
          )
        end
        line += 1
      end
    end
  end

  describe '.do_export' do
    let(:plugin) { MEDLINE }
    let(:target) {
      t = RayyanFormats::Target.new
      t.publication_types = ['Journal Article', 'Review']
      t.sid = '123456'
      t.title = 'A title for a research article'
      t.date_array = %w[2020 5 20]
      t.journal_title = 'A journal title'
      t.journal_issn = 'A journal issn'
      t.journal_abbreviation = 'A journal abbreviation'
      t.jvolume = 1
      t.jissue = 10
      t.pagination = 'pagination1'
      t.authors = ['a1_last_name a1_first_name', 'a2_last_name a2_first_name']
      t.affiliation = %w[University1 University2]
      t.language = %w[eng ger]
      t.publisher_location = 'publisher location'
      t.collection = 'collection1'
      t.keywords = %w[kw1 kw2 kw3 kw4]
      t.abstracts = ['This is abstract 1', 'This is abstract 2']
      t.notes = ['This is note1', 'This is note2']
      t
    }

    let(:target_s) {
      File.read('spec/support/example2.nbib')
    }

    let(:target_s_abstracts) {
      File.read('spec/support/example3.nbib')
    }

    it_behaves_like "correct target emitter"
  end

  describe '.get_date_array' do
    it 'returns correct dates' do
      expect(MEDLINE.get_date_array('2010')).to eq(%w[2010])
      expect(MEDLINE.get_date_array('2007 Jan')).to eq(%w[2007 1])
      expect(MEDLINE.get_date_array('2011 Jun 2')).to eq(%w[2011 6 2])
      expect(MEDLINE.get_date_array('2016 Oct-Dec')).to eq(%w[2016 10])
      expect(MEDLINE.get_date_array('2020 random 3')).to eq(%w[2020])
    end
  end

  describe '.convert_abbr_month_name_to_number' do
    it 'returns correct month number' do
      expect(MEDLINE.convert_abbr_month_name_to_number('Feb')).to eq(2)
      expect(MEDLINE.convert_abbr_month_name_to_number('May')).to eq(5)
      expect(MEDLINE.convert_abbr_month_name_to_number('Jun')).to eq(6)
      expect(MEDLINE.convert_abbr_month_name_to_number('December')).to eq(nil)
      expect(MEDLINE.convert_abbr_month_name_to_number('random')).to eq(nil)
    end
  end

  describe '.get_article_ids' do
    it 'returns correct article ids' do
      article = {
        'type' => '123456',
        'PMC' => 'pmcid',
        'AID' => ['some doi number', 'some pii number']
      }

      expect(MEDLINE.get_article_ids(article)).to eq(
        [
          { idtype: :pubmed_id, value: '123456' },
          { idtype: :pmc_id, value: 'pmcid' },
          { idtype: :doi, value: 'some doi number' },
          { idtype: :pii, value: 'some pii number' }
        ]
      )
    end
  end

  describe '.format_date_array' do
    it 'formats date array correctly' do
      expect(MEDLINE.format_date_array(['2020'])).to eq('2020')
      expect(MEDLINE.format_date_array(%w[2006 3])).to eq('2006 Mar')
      expect(MEDLINE.format_date_array(%w[2012 12 15])).to eq('2012 Dec 15')
    end
  end

  describe '.emit_line' do
    it 'emits line with key correctly' do
      expect(MEDLINE.emit_line('TI', 'A title')).to eq("TI  - A title\n")
      expect(MEDLINE.emit_line('PMID', '123456')).to eq("PMID- 123456\n")
    end
  end

  describe '.emit_lines_from_array' do
    it 'emits lines from array elements correctly' do
      expect(MEDLINE.emit_lines_from_array('AU', %w[author1 author2 author3])).to eq(
        ["AU  - author1\n", "AU  - author2\n", "AU  - author3\n"]
      )
      expect(MEDLINE.emit_lines_from_array('AB', 'abstract1')).to eq(
        ["AB  - abstract1\n"]
      )
    end
  end

  describe '.emit_article_id' do
    it 'emits article ids' do
      article_ids = [
        { idtype: :pubmed_id, value: '123456' },
        { idtype: :pmc_id, value: 'pmcid' },
        { idtype: :doi, value: 'some doi number' },
        { idtype: :pii, value: 'some pii number' }
      ]
      expect(MEDLINE.emit_article_id('PMC', :pmc_id, article_ids)).to eq("PMC - pmcid\n")
      expect(MEDLINE.emit_article_id('AID', :doi, article_ids)).to eq("AID - some doi number\n")
      expect(MEDLINE.emit_article_id('AID', :pii, article_ids)).to eq("AID - some pii number\n")
    end
  end
end
