require 'spec_helper'

describe RayyanFormats::Plugins::BibTeX do
  let(:plugin) { RayyanFormats::Plugins::BibTeX }

  describe ".detect" do
    it "returns false if it does not start with @article" do
      expect(plugin.send(:detect, "bad", [])).to eq(false)
    end

    it "returns true if it starts with @article" do
      expect(plugin.send(:detect, "@article {good}", [])).to eq(true)
    end
  end
    
  describe ".do_import" do
    let(:filename) { 'spec/support/example1.bib' }
    let(:body) { File.read(filename) }
    let(:expected_total) { 17 }

    it_behaves_like "repetitive target yielder"

    it "assigns correct values from first line" do
      line = 0
      plugin.send(:do_import, body, filename) do |target|
        case line
        when 0
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.sid).to eq("key1")
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
          expect(target.collection).to eq("collection1")
          expect(target.keywords).to eq(%w(kw1 kw2 kw3))
          expect(target.abstracts).to eq(["abstract1"])
          expect(target.notes).to eq("note1")
        when 1..12
          # test month name to number conversion for the 12 months
          expect(target.date_array).to eq(["2017", line.to_s])
        when 13
          expect(target.publication_types).to eq(["Conference Article"])
        when 14
          expect(target.publication_types).to eq(["Book"])
        when 15
          expect(target.publication_types).to eq(["Book"])
          expect(target.title).to eq("title - book_title")
          expect(target.authors).to eq(["editor"])
        when 16
          expect(target.publication_types).to eq(["phdthesis"])
          expect(target.affiliation).to eq("school")
        end
        line += 1
      end
    end
  end

  describe ".do_export" do
    let(:target) {
      t = RayyanFormats::Target.new
      t.sid = 'key1'
      t.title = 'title1'
      t.date_array = [2017, 4]
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
      t.collection = 'collection1'
      t.keywords = %w(kw1 kw2 kw3)
      t.abstracts = ['abstract1']
      t.notes = 'notes1'
      t
    }
    let(:target_s_abstracts) {
      File.read('spec/support/example3.bib')
    }
    let(:target_s) {
      File.read('spec/support/example2.bib')
    }

    it_behaves_like "correct target emitter"
  end

  describe ".get_unique_id" do
    let(:target) { double(sid: sid) }
    let(:generated_id) { "gid" }
    let(:options) { {unique_id: generated_id} }

    context "when target.sid is not empty" do
      let(:sid) { "abc" }

      it "returns target.sid" do
        expect(plugin.get_unique_id(target, options)).to eq(sid)
      end
    end

    context "when target.sid is nil" do
      let(:sid) { nil }

      it "returns generated id" do
        expect(plugin.get_unique_id(target, options)).to eq(generated_id)
      end
    end

    context "when target.sid is nothing but white spaces" do
      let(:sid) { "  \n\t  " }

      it "returns generated id" do
        expect(plugin.get_unique_id(target, options)).to eq(generated_id)
      end
    end
  end
end