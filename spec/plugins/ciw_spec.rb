require 'spec_helper'

include RayyanFormats::Plugins

describe ciw do
  describe ".detect" do
    it "returns false if it does not start with TY line" do
      expect(ciw.send(:detect, "bad", [])).to eq(false)
    end

    it "returns true if it starts with TY line" do
      expect(ciw.send(:detect, "FN", [])).to eq(true)
    end
  end
  
  describe ".do_import" do
    let(:filename) { 'spec/support/example1.ciw' }
    let(:body) { File.read(filename) }
    let(:expected_total) { 6 }
    let(:plugin) { ciw }

    it_behaves_like "repetitive target yielder"

    it "assigns correct values" do
      line = 0
      ciw.send(:do_import, body, filename) do |target|
        expect(target.authors).to eq(["Eltabakh, Mohamed        Aref, Walid        Elmagarmid, Ahmed        Ouzzani, Mourad"])
        case line
        when 1
       target = Target.new 
		  expect(target.publication_types).to eq(["Journal Article"])
          expect(target.Document_type).to eq(["Article"])
          expect(target.title).to eq("title1")
          expect(target.date_array).to eq(["2014", "SEP"])
          expect(target.pagination).to eq("2193-2206")
          expect(target.abstracts).to eq("abstract")
          expect(target.publisher_location).to eq("Qatar")
          expect(target.journal_title).to eq("journal1")
          expect(target.journal_abbreviation).to eq("Clin. Genet")
		  expect(target.jvolume).to eq(26)
		  expect(target.jissue).to eq(9)
		  expect(target.url).to eq("www.rayyan.qcri.com")
		  expect(target.language).to eq("ENGLISH")
		  expect(target.Document_type).to eq("Article")
          expect(target.journal_issn).to eq("1041-4347") 
		  expect(target.ISI_unique_article_identifier).to eq("WOS:000341571100009")
		  
		  when 2
		  expect(target.authors).to eq(["Sheikine, Y        Kuo, FC        Lindeman, NI", "Sheikine, Yuri"])
          expect(target.title).to eq("Title2")
          expect(target.date_array).to eq(["2017", "MAR", "20"])
          expect(target.jvolume).to eq(35)
          expect(target.jissue).to eq(10)
          expect(target.pagination).to eq("929-933")
          expect(target.keywords).to eq(["DECISION-SUPPORT", "HEALTH SYSTEM"])
          expect(target.abstracts).to eq("abstarct2")
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.publisher_name).to eq("Publisher")
          expect(target.publisher_location).to eq("USA")
          expect(target.journal_title).to eq("JOURNAL OF CLINICAL ONCOLOGY")
		  expect(target.Research_field).to eq("Genetics & Heredity") 
        end
        line += 1
      end
    end
  end
end