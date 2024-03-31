require "spec_helper"
require "obj_ruby/foundation"

class TestXMLParserDelegate < ObjRuby::NSObject
  attr_accessor :starts
  attr_accessor :ends

  def parser_didStartElement_namespaceURI_qualifiedName_attributes(parser, element, namespace, name, attributes)
    @starts ||= 0
    @starts += 1
  end

  def parser_didEndElement_namespaceURI_qualifiedName(parser, element, namespace, name)
    @ends ||= 0
    @ends += 1
  end
end

TEST_XML = <<~XML
  <root>
    <child/>
  </root>
XML

RSpec.describe ObjRuby::NSXMLParser do
  it "can take a delegate" do
    ObjRuby.register_class(TestXMLParserDelegate)

    xml = ObjRuby::NSString.stringWithString(TEST_XML)
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
