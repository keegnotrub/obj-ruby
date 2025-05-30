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

  describe "when accessing a pointer that hasn't been set yet" do
    it "returns nil" do
      ptrs = [
        described_class.new(:object),
        described_class.new(:bool),
        described_class.new(:char),
        described_class.new(:uchar),
        described_class.new(:short),
        described_class.new(:ushort),
        described_class.new(:int),
        described_class.new(:uint),
        described_class.new(:long),
        described_class.new(:ulong),
        described_class.new(:long_long),
        described_class.new(:ulong_long),
        described_class.new(:float),
        described_class.new(:double)
      ]

      ptrs.each do |ptr|
        expect(ptr[0]).to be_nil
      end
    end
  end

  describe "when passing pointer as a param" do
    it "sets NSError data for an object pointer" do
      error_ptr = described_class.new(:object)

      result = ObjRuby::NSData.dataWithContentsOfFile_options_error("not-a-path", 0, error_ptr)

      expect(result).to be_nil

      error = error_ptr[0]

      expect(error).not_to be_nil
      expect(error).to be_a ObjRuby::NSError
      expect(error.localizedDescription).to eq(
        "The file “not-a-path” couldn’t be opened because there is no such file."
      )
      expect(error_ptr[-1]).to eq error
      expect(error_ptr[1]).to be_nil
    end

    it "sets CGFloat data for a value pointer" do
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

    it "sets a block of CGFloat data for an array of value pointers" do
      components = described_class.new(:double, 4)

      color = ObjRuby::NSColor.greenColor

      color.getComponents(components)

      expect(components[0]).to eq(0.0)
      expect(components[1]).to eq(1.0)
      expect(components[2]).to eq(0.0)
      expect(components[3]).to eq(1.0)
      expect(components[4]).to be_nil

      expect(components[-1]).to eq(components[3])
      expect(components[-2]).to eq(components[2])
      expect(components[-3]).to eq(components[1])
      expect(components[-4]).to eq(components[0])
      expect(components[-5]).to be_nil

      expect(components[0, 4]).to eq([0.0, 1.0, 0.0, 1.0])
      expect(components[0, 9]).to eq([0.0, 1.0, 0.0, 1.0])
      expect(components[1, 2]).to eq([1.0, 0.0])
      expect(components[-1, 1]).to eq([1.0])
      expect(components[-1, 9]).to eq([1.0])
      expect(components[1, 0]).to eq([])
      expect(components[5, 1]).to be_nil
    end
  end
end
