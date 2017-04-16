require 'spec_helper'

describe RayyanFormats::Plugins::BibTeX do
  describe ".detect" do
    it "returns false if it does not start with @article" do
      expect(RayyanFormats::Plugins::BibTeX.send(:detect, "bad", [])).to eq(false)
    end

    it "returns true if it starts with @article" do
      expect(RayyanFormats::Plugins::BibTeX.send(:detect, "@article {good}", [])).to eq(true)
    end
  end
    
  describe ".do_import" do
    let(:filename) { 'spec/support/example1.bib' }
    let(:body) { File.read(filename) }
    let(:expected_total) { 13 }
    let(:plugin) { RayyanFormats::Plugins::BibTeX }

    it_behaves_like "repetitive target yielder"

    it "assigns correct values from first line" do
      line = 0
      RayyanFormats::Plugins::BibTeX.send(:do_import, body, filename) do |target|
        if line == 0
          expect(target.sid).to eq("key1")
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.title).to eq("title1")
          expect(target.date_array).to eq(["2017"])
          expect(target.jvolume).to eq(1)
          expect(target.jissue).to eq(10)
          expect(target.pagination).to eq("pages1")
          expect(target.authors).to eq(["a1l, a1f", "a2l, a2f", "a3l, a3f", "a4l, a4f"])
          expect(target.url).to eq("url1")
          expect(target.abstracts).to eq(["abstract1"])
          expect(target.publisher_name).to eq("publisher1")
          expect(target.publisher_location).to eq("location1")
          expect(target.journal_title).to eq("journal1")
          expect(target.affiliation).to eq("affiliation1")
          expect(target.collection).to eq("collection1")
        else
          # test month name to number conversion for the 12 months
          expect(target.date_array).to eq(["2017", line.to_s])
        end
        line += 1
      end
    end

  end
end