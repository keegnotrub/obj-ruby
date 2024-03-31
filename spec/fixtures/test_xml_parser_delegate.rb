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
