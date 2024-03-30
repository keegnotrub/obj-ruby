require "spec_helper"
require "obj_ruby/foundation"

class TestXMLParserDelegate
  def parser_didStartElement_namespaceURI_qualifiedName_attributes(parser, element, namespace, name, attributes)
  end

  def parser_didEndElement_namespaceURI_qualifiedName(parser, element, namespace, name)
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

    allow_any_instance_of(TestXMLParserDelegate).to receive(:parser_didStartElement_namespaceURI_qualifiedName_attributes)
    allow_any_instance_of(TestXMLParserDelegate).to receive(:parser_didEndElement_namespaceURI_qualifiedName)

    xml = ObjRuby::NSString.stringWithString(TEST_XML)
    data = xml.dataUsingEncoding(ObjRuby::NSUTF8StringEncoding)
    parser = ObjRuby::NSXMLParser.alloc.initWithData(data)

    delegate = TestXMLParserDelegate.new
    parser.setDelegate(delegate)

    result = parser.parse

    expect(result).to eq(true)
    expect(delegate).to have_received(:parser_didStartElement_namespaceURI_qualifiedName_attributes).twice
    expect(delegate).to have_received(:parser_didEndElement_namespaceURI_qualifiedName).twice
  end
end
