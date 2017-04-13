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
  end
end