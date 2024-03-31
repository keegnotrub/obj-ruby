require "spec_helper"
require "obj_ruby/foundation"
require_relative "../fixtures/test_xml_parser_delegate"

RSpec.describe ObjRuby::NSXMLParser do
  it "can take a delegate" do
    ObjRuby.register_class(TestXMLParserDelegate)

    xml = ObjRuby::NSString.stringWithString(<<~XML)
      <root>
        <child/>
      </root>
    XML

    data = xml.dataUsingEncoding(ObjRuby::NSUTF8StringEncoding)
    parser = ObjRuby::NSXMLParser.alloc.initWithData(data)

    delegate = TestXMLParserDelegate.new
    parser.setDelegate(delegate)

    result = parser.parse

    expect(result).to eq(true)
    expect(delegate.starts).to eq(2)
    expect(delegate.ends).to eq(2)
  end
end
