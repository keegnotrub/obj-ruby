require "securerandom"

module ObjRuby
  class Assets
    SUPPORTED_TYPES = {
      ".xib" => "file.xib",
      ".gif" => "image.gif",
      ".png" => "image.png"
    }

    Asset = Struct.new(:id, :path) do
      def type
        SUPPORTED_TYPES[path.extname]
      end

      def file
        path.basename
      end
    end

    def initialize
      @assets = []
    end

    def each(&block)
      @assets.each(&block)
    end

    def append_file(asset_file)
      asset = Asset.new(SecureRandom.hex(12).upcase, asset_file)
      if !asset.type.nil?
        @assets << asset
      end
    end
  end
end
