require 'spec_helper'

include RayyanFormats::Plugins

describe GZ do
  describe ".do_import" do
    let(:body) { File.read(filename) }
    let(:decompressed_body) { "gzipped content\n" }
    let(:plugin) { double(do_import: true) }

    before {
      allow(GZ).to receive(:match_plugin).with('txt') { plugin }
    }

    shared_examples "gz reader" do
      it "decompresses the input file and delegates to the matching plugin" do
        expect(plugin).to receive(:do_import).with(decompressed_body, decompressed_filename)
        GZ.send(:do_import, body, filename)
      end
    end

    context "when the compressed file has an extension" do
      let(:filename) { 'spec/support/example1.txt.gz' }
      let(:decompressed_filename) { 'spec/support/example1.txt' }

      it_behaves_like 'gz reader'
    end

    context "when the compressed file does not have an extension" do
      let(:filename) { 'spec/support/example2.gz' }
      let(:decompressed_filename) { 'spec/support/example2' }
      
      it_behaves_like 'gz reader'
    end

  end
end