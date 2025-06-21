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
    it "returns nil for an object" do
      expect(described_class.new(:object)[0]).to be_nil
    end

    it "returns false for a bool" do
      expect(described_class.new(:bool)[0]).to be false
    end

    it "returns zero for numerics" do
      expect(described_class.new(:char)[0]).to eq 0
      expect(described_class.new(:uchar)[0]).to eq 0
      expect(described_class.new(:short)[0]).to eq 0
      expect(described_class.new(:ushort)[0]).to eq 0
      expect(described_class.new(:int)[0]).to eq 0
      expect(described_class.new(:uint)[0]).to eq 0
      expect(described_class.new(:long)[0]).to eq 0
      expect(described_class.new(:ulong)[0]).to eq 0
      expect(described_class.new(:long_long)[0]).to eq 0
      expect(described_class.new(:ulong_long)[0]).to eq 0
      expect(described_class.new(:float)[0]).to eq 0
      expect(described_class.new(:double)[0]).to eq 0
    end
  end

  describe "when passing a pointer as a param" do
    it "passes the supplied data as intended" do
      ptr = described_class.new(:ulong, 3)

      ptr[0] = 8
      ptr[1] = 9
      ptr[2] = 10

      index_path = ObjRuby::NSIndexPath.alloc.initWithIndexes_length(ptr, 3)

      expect(index_path.length).to eq 3
      expect(index_path.indexAtPosition(0)).to eq 8
      expect(index_path.indexAtPosition(1)).to eq 9
      expect(index_path.indexAtPosition(2)).to eq 10
    end
  end

  describe "when passing pointer as an out param" do
    it "sets NSError data for an object pointer" do
      error_ptr = described_class.new(:object)

      result = ObjRuby::NSData.dataWithContentsOfFile_options_error("not-a-path", 0, error_ptr)

      expect(result).to be_nil

      error = error_ptr[0]

      expect(error).not_to be_nil
      expect(error).to be_a ObjRuby::NSError
      expect(error.localizedDescription).to eq(
        ObjRuby::NSString("The file “not-a-path” couldn’t be opened because there is no such file.")
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
