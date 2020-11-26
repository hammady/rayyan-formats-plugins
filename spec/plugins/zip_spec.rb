require 'spec_helper'

describe RayyanFormats::Plugins::Zip do
  describe ".do_import" do
    context "when input file is not in zip format" do
      let(:filename) { 'filename' }
      let(:body) { 'not zip format' }

      it "raises an error" do
        expect{
          RayyanFormats::Plugins::Zip.send(:do_import, body, filename)
        }.to raise_error Zip::Error
      end
    end

    context "when input file is in zip format" do
      let(:filename) { 'spec/support/example1.zip' }
      let(:body) { File.read(filename) }
      let(:text_plugin) { double(do_import: true) }
      let(:csv_plugin) { double(do_import: true) }
      let(:target) { double }

      before {
        allow(RayyanFormats::Plugins::Zip).to receive(:match_import_plugin) { nil }
      }

      context "when input file has no valid supported entries" do
        it "decompresses the file but raises an error complaining about no supported entries" do
          expect{
            RayyanFormats::Plugins::Zip.send(:do_import, body, filename)
          }.to raise_error RuntimeError, /^Zip file has no supported entries/
        end
      end

      context "when input file has valid supported entries" do
        before {
          allow(RayyanFormats::Plugins::Zip).to receive(:match_import_plugin).with('txt') { text_plugin }
          allow(RayyanFormats::Plugins::Zip).to receive(:match_import_plugin).with('csv') { csv_plugin }
        }

        context "if there is no converter given" do
          let(:converter) { nil }

          it "decompresses the file and handles supported entries" do
            expect(text_plugin).to receive(:do_import).with("text content\n", "dummy.txt", converter)
            expect(csv_plugin).to receive(:do_import).with("csv content\n", "dummy.csv", converter)
            RayyanFormats::Plugins::Zip.send(:do_import, body, filename, converter)
          end
        end

        context "if a converter is given" do
          let(:converter) { ->(body, ext) { "converted #{body}.#{ext}" } }

          it "converts then decompresses the file and handles supported entries" do
            expect(text_plugin).to receive(:do_import).with("converted text content\n.txt", "dummy.txt", converter)
            expect(csv_plugin).to receive(:do_import).with("converted csv content\n.csv", "dummy.csv", converter)
            RayyanFormats::Plugins::Zip.send(:do_import, body, filename, converter)
          end
        end

        it "incrementally computes total articles from each entry" do
          text_plugin_total, csv_plugin_total = 3, 5
          # allow each plugin.do_import to yield target, sub_total 2 times (2 articles in each)
          expect(text_plugin).to receive(:do_import)
            .and_yield(target, text_plugin_total).and_yield(target, text_plugin_total)

          expect(csv_plugin).to receive(:do_import)
            .and_yield(target, csv_plugin_total).and_yield(target, csv_plugin_total)

          # expect parse_zip to yield incremental total
          final_total = nil
          RayyanFormats::Plugins::Zip.send(:do_import, body, filename) do |target, total|
            final_total = total
          end
          expect(final_total).to eq(text_plugin_total + csv_plugin_total)
        end
      end
    end

  end
end
