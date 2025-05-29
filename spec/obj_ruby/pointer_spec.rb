# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::Pointer do
  describe "creating an instance of pointer" do
    it "can create an instance pointing to single type encoding" do
      ptr = described_class.new(:double)

      expect(ptr).not_to be_nil
      expect(ptr).to be_a described_class
    end

    it "can create an instance pointing to an array of a type encoding" do
      ptr = described_class.new(:double, 10)

      expect(ptr).not_to be_nil
      expect(ptr).to be_a described_class
    end

    it "raises an error if not provided the type encoding" do
      expect do
        described_class.new
      end.to raise_error(ArgumentError)
    end
  end

  describe "when passing pointer as a param" do
    it "sets NSError data for an object pointer" do
      error_ptr = described_class.new(:object)

      result = ObjRuby::NSData.dataWithContentsOfFile_options_error("not-a-path", 0, error_ptr)

      expect(result).to be_nil

      error = error_ptr.at(0)

      expect(error).not_to be_nil
      expect(error).to be_a ObjRuby::NSError
      expect(error.localizedDescription).to eq(
        "The file “not-a-path” couldn’t be opened because there is no such file."
      )
      expect(error_ptr[0]).to eq error

      array = error_ptr.slice(0, 1)

      expect(array[0]).to eq error
      expect(error_ptr[0, 1]).to eq array
    end

    it "sets CGFloat data for a value pointers" do
      red = described_class.new(:double)
      green = described_class.new(:double)
      blue = described_class.new(:double)
      alpha = described_class.new(:double)

      color = ObjRuby::NSColor.redColor

      color.getRed_green_blue_alpha(red, green, blue, alpha)

      expect(red[0]).to eq(1.0)
      expect(green[0]).to eq(0.0)
      expect(blue[0]).to eq(0.0)
      expect(alpha[0]).to eq(1.0)
    end
  end
end
