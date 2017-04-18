require 'spec_helper'

include RayyanFormats::Plugins

describe EndNote do
  describe ".detect" do
    it "returns false if it does not start with %0" do
      expect(EndNote.send(:detect, "bad", [])).to eq(false)
    end

    it "returns true if it starts with %0" do
      expect(EndNote.send(:detect, "%0 good", [])).to eq(true)
    end
  end

  describe ".do_import" do
    let(:filename) { 'spec/support/example1.enw' }
    let(:body) { File.read(filename) }
    let(:expected_total) { 2 }
    let(:plugin) { EndNote }

    it_behaves_like "repetitive target yielder"

    it "assigns correct values" do
      first_line = true
      EndNote.send(:do_import, body, filename) do |target|
        if first_line
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.sid).to eq("123456")
          expect(target.title).to eq("title1")
          expect(target.date_array).to eq(["2017"])
          expect(target.journal_title).to eq("journal1")
          expect(target.journal_issn).to eq("issn1")
          expect(target.jvolume).to eq(1)
          expect(target.jissue).to eq(10)
          expect(target.pagination).to eq("pages1")
          expect(target.authors).to eq(["a1l, a1f", "a2l, a2f", "a3l, a3f", "a4l, a4f"])
          expect(target.affiliation).to eq("affiliation1")
          expect(target.url).to eq("url1")
          expect(target.language).to eq("lang1")
          expect(target.publisher_name).to eq("publisher1")
          expect(target.publisher_location).to eq("location1")
          expect(target.keywords).to eq((1..15).map{|i| "kw#{i}"})
          expect(target.abstracts).to eq(["abstract1"])
          expect(target.notes).to eq("notes1")
        else
          expect(target.publication_types).to eq(["Another type"])
          expect(target.journal_title).to eq("journal2")
          expect(target.authors).to eq(["a1l, a1f", "a2l, a2f", "a3l, a3f", "a4l, a4f"])
          expect(target.url).to eq("url2")
        end
        first_line = false
      end
    end
  end

  describe ".do_export" do
    let(:plugin) { EndNote }
    let(:target) {
      t = RayyanFormats::Target.new
      t.publication_types = ['Journal Article']
      t.sid = 'key1'
      t.title = 'title1'
      t.date_array = [2017, 4, 15]
      t.journal_title = 'journal1'
      t.journal_issn = 'issn1'
      t.jvolume = 1
      t.jissue = 10
      t.pagination = 'pages1'
      t.authors = ['al1, af1', 'al2, af2']
      t.affiliation = 'affiliation1'
      t.url = 'url1'
      t.language = 'lang1'
      t.publisher_name = 'publisher1'
      t.publisher_location = 'location1'
      t.keywords = %w(kw1 kw2 kw3)
      t.abstracts = ['abstract1', 'abstract2']
      t.notes = 'notes1'
      t
    }
    let(:target_s_abstracts) {
      File.read('spec/support/example3.enw')
    }
    let(:target_s) {
      File.read('spec/support/example2.enw')
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
end