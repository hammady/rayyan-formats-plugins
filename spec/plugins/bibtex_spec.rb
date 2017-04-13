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
  end
end