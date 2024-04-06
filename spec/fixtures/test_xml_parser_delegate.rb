class TestXMLParserDelegate < ObjRuby::NSObject
  attr_accessor :starts
  attr_accessor :ends

  def init
    @starts = 0
    @ends = 0

    self
  end

  def parser_didStartElement_namespaceURI_qualifiedName_attributes(parser, element, namespace, name, attributes)
    @starts += 1
  end

  def parser_didEndElement_namespaceURI_qualifiedName(parser, element, namespace, name)
    @ends += 1
  end
end
