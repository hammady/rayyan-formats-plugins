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
          expect(target.title).to eq("title1")
          expect(target.date_array).to eq(["2017"])
          expect(target.jvolume).to eq(1)
          expect(target.jissue).to eq(10)
          expect(target.pagination).to eq("pages1")
          expect(target.authors).to eq(["a1l, a1f", "a2l, a2f", "a3l, a3f", "a4l, a4f"])
          expect(target.url).to eq("url1")
          expect(target.language).to eq("lang1")
          expect(target.notes).to eq("notes1")
          expect(target.abstracts).to eq(["abstract1"])
          expect(target.publication_types).to eq(["Journal Article"])
          expect(target.publisher_name).to eq("publisher1")
          expect(target.publisher_location).to eq("location1")
          expect(target.journal_title).to eq("journal1")
          expect(target.journal_issn).to eq("issn1")
        else
          expect(target.publication_types).to eq(["Another type"])
          expect(target.authors).to eq(["a1l, a1f", "a2l, a2f", "a3l, a3f", "a4l, a4f"])
          expect(target.url).to eq("url2")
          expect(target.journal_title).to eq("journal2")
        end
        first_line = false
      end
    end
  end
end