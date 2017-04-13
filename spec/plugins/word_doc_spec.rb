require 'spec_helper'

include RayyanFormats::Plugins

describe WordDocument do
  describe ".do_import" do
    shared_examples "word doc reader" do
      it "reads text from word doc and delegates to the plain text plugin" do
        expect(PlainText).to receive(:do_import).with(plain_text_body, filename)
        WordDocument.send(:do_import, body, filename)
      end
    end

    let(:body) { File.read(filename) }

    context "old word doc format" do
      let(:filename) { 'spec/support/example1-oldformat.docx' }
      let(:plain_text_body) { "docx plain content old format\n" }

      it_behaves_like "word doc reader"
    end

    context "new word doc format" do
      let(:filename) { 'spec/support/example2-newformat.docx' }
      let(:plain_text_body) { "docx plain content new format\n" }

      it_behaves_like "word doc reader"
    end

  end
end