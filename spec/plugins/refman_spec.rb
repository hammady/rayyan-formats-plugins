require 'spec_helper'

include RayyanFormats::Plugins

describe Refman do
  describe ".detect" do
    it "returns false if it does not start with TY line" do
      expect(Refman.send(:detect, "bad", [])).to eq(false)
    end

    it "returns true if it starts with TY line" do
      expect(Refman.send(:detect, "TY  - good", [])).to eq(true)
    end
  end
  
  describe ".do_import" do
    let(:filename) { 'spec/support/example1.ris' }
    let(:body) { File.read(filename) }
    let(:expected_total) { 6 }
    let(:plugin) { Refman }

    it_behaves_like "repetitive target yielder"

    it "assigns correct values" do
      line = 0
      Refman.send(:do_import, body, filename) do |target|
        expect(target.authors).to eq(["a1l, a1f", "a2l, a2f", "a3l, a3f", "a4l, a4f", "a5l, a5f"])
        case line
        when 0
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.sid).to eq("key1")
          expect(target.title).to eq("title1")
          expect(target.date_array).to eq(["2017", "10", "1"])
          expect(target.journal_title).to eq("journal1")
          expect(target.journal_issn).to eq("issn1")
          expect(target.journal_abbreviation).to eq("j1")
          expect(target.jvolume).to eq(1)
          expect(target.jissue).to eq(10)
          expect(target.pagination).to eq("pages1")
          expect(target.affiliation).to eq("affiliation1")
          expect(target.url).to eq("url1")
          expect(target.language).to eq("lang1")
          expect(target.publisher_name).to eq("publisher1")
          expect(target.publisher_location).to eq("location1 city1")
          expect(target.collection).to eq("collection1")
          expect(target.keywords).to eq((1..15).map{|i| "kw#{i}"})
          expect(target.abstracts).to eq(["abstract1", "abstract2"])
          expect(target.notes).to eq("notes1")
        when 1
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.title).to eq("title2")
          expect(target.date_array).to eq(["2017", "10", "1"])
          expect(target.journal_title).to eq("journal1")
          expect(target.journal_abbreviation).to eq("j1")
          expect(target.jissue).to eq(10)
          expect(target.pagination).to eq("pages1-pages2")
          expect(target.publisher_location).to eq("location1")
          expect(target.abstracts).to eq(["abstract1"])
        when 2
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.title).to eq("title3")
          expect(target.date_array).to eq(["2017", "10", "1"])
          expect(target.journal_title).to eq("journal1")
          expect(target.journal_abbreviation).to eq("j1")
          expect(target.pagination).to eq("-pages2")
          expect(target.publisher_location).to eq("city1")
          expect(target.abstracts).to eq(["abstract1", "abstract2"])
        when 3
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.title).to eq("title4")
          expect(target.date_array).to eq(["2017", "10", "1"])
          expect(target.journal_title).to eq("journal1")
          expect(target.pagination).to eq("")
          expect(target.publisher_location).to eq("")
        when 4
          expect(target.publication_types).to eq(["Thesis"])
          expect(target.title).to eq("title5")
          expect(target.date_array).to eq(["2017", "10", "1"])
        when 5
          expect(target.publication_types).to eq(["OTHER_PUBTYPE"])
          expect(target.title).to eq("title6")
        end
        line += 1
      end
    end
  end

  describe ".do_export" do
    let(:plugin) { Refman }
    let(:target) {
      t = RayyanFormats::Target.new
      t.publication_types = ['Journal Article']
      t.sid = 'key1'
      t.title = 'title1'
      t.date_array = [2017, 4, 15]
      t.journal_title = 'journal1'
      t.journal_issn = 'issn1'
      t.journal_abbreviation = 'abbrev1'
      t.jvolume = 1
      t.jissue = 10
      t.pagination = 'pages1'
      t.authors = ['al1, af1', 'al2, af2']
      t.affiliation = 'affiliation1'
      t.url = 'url1'
      t.language = 'lang1'
      t.publisher_name = 'publisher1'
      t.publisher_location = 'location1'
      t.collection = 'collection1'
      t.keywords = %w(kw1 kw2 kw3)
      t.abstracts = ['abstract1', 'abstract2']
      t.notes = 'notes1'
      t
    }
    let(:target_s_abstracts) {
      File.read('spec/support/example3.ris')
    }
    let(:target_s) {
      File.read('spec/support/example2.ris')
    }

    it "emits target if not nil (without abstracts)" do
      output = plugin.send(:do_export, target, {include_abstracts: false})
      expect(output).to eq(target_s)
    end

    it "emits target if not nil (with abstracts)" do
      output = plugin.send(:do_export, target, {include_abstracts: true})
      expect(output).to eq(target_s_abstracts)
    end

    it "does not emit target if nil" do
      output = plugin.send(:do_export, nil, {})
      expect(output).not_to eq(target_s)
    end
  end

  describe ".get_publication_types" do
    it "returns Journal Article" do
      %w(JOUR ELEC ABST EJOUR).each do |pubtype|
        expect(Refman.get_publication_types(pubtype)).to eq(["Journal Article"])
      end
    end

    it "returns Thesis" do
      expect(Refman.get_publication_types("THES")).to eq(["Thesis"])
    end

    it "returns publication type verbatim" do
      expect(Refman.get_publication_types("foo")).to eq(["foo"])
    end
  end

  describe ".set_publication_type" do
    it "returns JOUR" do
      expect(Refman.set_publication_type("Journal Article")).to eq("JOUR")
    end

    it "returns THES" do
      expect(Refman.set_publication_type("Thesis")).to eq("THES")
    end

    it "returns publication type verbatim" do
      expect(Refman.set_publication_type("foo")).to eq("foo")
    end
  end

end
