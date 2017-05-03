require 'spec_helper'

include RayyanFormats::Plugins

describe CIW do
  describe ".detect" do
    it "returns false if it does not start with FN line" do
      expect(CIW.send(:detect, "bad", [])).to eq(false)
    end

    it "returns true if it starts with FN line" do
      expect(CIW.send(:detect, "FN", [])).to eq(true)
    end
  end
  
  describe ".do_import" do
    let(:filename) { 'spec/support/example1.ciw' }
    let(:body) { File.read(filename) }
    let(:expected_total) { 2 }
    let(:plugin) { CIW }

    it_behaves_like "repetitive target yielder"

    it "assigns correct values" do
      line = 0
      CIW.send(:do_import, body, filename) do |target|
      case line
        when 0
          expect(target.publication_types).to eq(["Journal Article"])
		      expect(target.title).to eq("title1")
          expect(target.authors).to eq(["a1l, a1f", "a2l, a2f", "a3l, a3f"])
		      expect(target.date_array).to eq(["2014", "9", "1"])
		      expect(target.pagination).to eq("page1")
		      expect(target.abstracts).to eq([["abstract1a", "   abstract1b"].join(::RefParsers::NEWLINE_MERGER), "abstract2"])
		      expect(target.journal_issn).to eq("issn1")
		      expect(target.publisher_name).to eq("publisher1")
		      expect(target.publisher_location).to eq("location1")
		      expect(target.journal_title).to eq("journal1")
		      expect(target.journal_abbreviation).to eq("abbrev1")
		      expect(target.jvolume).to eq(10)
		      expect(target.jissue).to eq(1)
		      expect(target.url).to eq("url1")
          expect(target.keywords).to eq((1..3).map{|i| "kw#{i}"})
		      expect(target.language).to eq("lang1") 
		      expect(target.sid).to eq("key1")
        when 1
          expect(target.publication_types).to eq(["Conference Proceedings"])
          expect(target.title).to eq("title2")
          expect(target.date_array).to eq(["2018", "11", "1"])
          expect(target.journal_title).to eq("journal2")
          expect(target.journal_abbreviation).to eq("abbrev2")
          expect(target.jissue).to eq(10)
          expect(target.jvolume).to eq(20)
        end
        line += 1
      end
    end
  end
end

  describe ".do_export" do
    let(:plugin) { CIW }
    let(:target) {
      t = RayyanFormats::Target.new
	    t.publication_types = ['Journal Article']
	    t.authors = ["a1l, a1f","a2l, a2f","a3l, a3f"]
	    t.title = 'title1' 
	    t.journal_title = 'journal1'
	    t.date_array = [2014, 9, 1]
	    t.pagination = "pages1"
	    t.abstracts = ["abstract1", "abstract2"]
	    t.journal_issn ="issn1"
	    t.publisher_name ="publisher1"
	    t.publisher_location= "location1"
	    t.journal_abbreviation ="abbrev1"
	    t.jvolume = 10
	    t.jissue = 1
	    t.url = "url1"
	    t.keywords = %w(kw1 kw2 kw3)
	    t.language = "lang1"
      t.sid = "key1"
	    t
    }
    let(:target_s_abstracts) {
      File.read('spec/support/example2.ciw')
    }
    let(:target_s) {
      File.read('spec/support/example3.ciw')
     }

    it_behaves_like "correct target emitter"    
  end

  describe ".get_publication_types" do
    it "returns Journal Article" do
      %w(J).each do |pubtype|
        expect(CIW.get_publication_types(pubtype)).to eq(["Journal Article"])
      end
    end

    it "returns Conference Proceedings" do
      expect(CIW.get_publication_types("S")).to eq(["Conference Proceedings"])
    end
  end

  describe ".set_publication_type" do
    it "returns J" do
      expect(CIW.set_publication_type("Journal Article")).to eq("J")
    end
    it "returns S" do
      expect(CIW.set_publication_type("Conference Proceedings")).to eq("S")
    end
  end