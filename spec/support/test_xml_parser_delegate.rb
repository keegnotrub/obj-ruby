# frozen_string_literal: true

class TestXMLParserDelegate < ObjRuby::NSObject
  attr_accessor :starts, :ends

  def init
    @starts = 0
    @ends = 0

    self
  end

  def parser_didStartElement_namespaceURI_qualifiedName_attributes(_parser, _element, _namespace, _name, _attributes)
    @starts += 1
  end

  def parser_didEndElement_namespaceURI_qualifiedName(_parser, _element, _namespace, _name)
    @ends += 1
  end
end
