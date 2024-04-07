require "spec_helper"

RSpec.describe ObjRuby do
  describe "#root" do
    it "returns nil without the needed ENV var" do
      with_modified_env OBJR_ROOT: nil do
        expect(described_class.root).to be_nil
      end
    end

    it "returns the path set by the needed ENV var" do
      with_modified_env OBJR_ROOT: "/my/path" do
        expect(described_class.root).to eq("/my/path")
      end
    end

    it "can extend the path set by the needed ENV var" do
      with_modified_env OBJR_ROOT: "/my/path" do
        result = described_class.root "extended", "path"
        expect(result).to eq("/my/path/extended/path")
      end
    end
  end

  describe "#initialize!" do
    it "calls register_class for found Ruby classes" do
      with_modified_env OBJR_ROOT: source_root do
        allow(described_class).to receive(:register_class)

        described_class.initialize!

        expect(described_class).to have_received(:register_class).once
      end
    end
  end
end
