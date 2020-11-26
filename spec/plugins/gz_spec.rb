require 'spec_helper'

include RayyanFormats::Plugins

describe GZ do
  describe ".do_import" do
    let(:body) { File.read(filename) }
    let(:decompressed_body) { "gzipped content\n" }
    let(:plugin) { double(do_import: true) }
    let(:converter) { nil }

    before {
      allow(GZ).to receive(:match_import_plugin).with('txt') { plugin }
    }

    shared_examples "gz reader" do
      it "decompresses the input file and delegates to the matching plugin" do
        expect(plugin).to receive(:do_import).with(decompressed_body, decompressed_filename, converter)
        GZ.send(:do_import, body, filename, converter)
      end
    end

    context "when the compressed file has an extension" do
      let(:filename) { 'spec/support/example1.txt.gz' }
      let(:decompressed_filename) { 'spec/support/example1.txt' }

      context "if there is no converter given" do
        let(:converter) { nil }
        it_behaves_like 'gz reader'
      end

      context "if a converter is given" do
        let(:converter) { ->(body, ext) { "converted #{body}.#{ext}" } }
        let(:decompressed_body) { "converted gzipped content\n.txt" }
        it_behaves_like 'gz reader'
      end
    end

    context "when the compressed file does not have an extension" do
      let(:filename) { 'spec/support/example2.gz' }
      let(:decompressed_filename) { 'spec/support/example2' }

      it_behaves_like 'gz reader'
    end

  end
end
