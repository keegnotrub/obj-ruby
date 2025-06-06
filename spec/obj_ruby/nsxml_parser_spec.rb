# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSXMLParser do
  it "can take a delegate" do
    xml = ObjRuby::NSString.stringWithString(example_xml)

    data = xml.dataUsingEncoding(ObjRuby::NSUTF8StringEncoding)
    parser = described_class.alloc.initWithData(data)

    delegate = TestXMLParserDelegate.new
    parser.delegate = delegate

    result = parser.parse

    expect(result).to be true
    expect(delegate.starts).to eq(2)
    expect(delegate.ends).to eq(2)
  end

  def example_xml
    <<~XML
      <root>
        <child/>
      </root>
    XML
  end
end
