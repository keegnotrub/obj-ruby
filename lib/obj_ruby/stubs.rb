require "prism"
require "tsort"

module ObjRuby
  class Stubs < Prism::Visitor
    include TSort

    StubClass = Struct.new(:class_name, :superclass_name, :outlets, :actions)
    IBAction = Struct.new(:id)
    IBOutlet = Struct.new(:id)

    alias_method :each, :tsort_each

    def initialize
      super
      @classes = {}
    end

    def append_file(rb_file)
      result = Prism.parse_file(rb_file.to_path)
      return false if !result.success?

      result.value.accept(reset)

      if writable?
        @classes[@class_name] = StubClass.new(
          @class_name,
          @superclass_name,
          @outlets,
          @actions
        )
        true
      else
        false
      end
    end

    def tsort_each_node(&block)
      @classes.each_value(&block)
    end

    def tsort_each_child(node, &block)
      [@classes[node.superclass_name]].compact.each(&block)
    end

    def visit_class_node(node)
      @class_name = node.name
      @superclass_name = superclass_name_from_class_node(node)
      super
    end

    def visit_call_node(node)
      case node.name
      when :ib_outlet
        @outlets << IBOutlet.new(node.arguments.arguments.first.unescaped)
      when :ib_action
        @actions << IBAction.new(node.arguments.arguments.first.unescaped)
      end
      super
    end

    private

    def writable?
      !@class_name.nil? && (@outlets.any? || @actions.any?)
    end

    def reset
      @class_name = nil
      @superclass_name = nil
      @outlets = []
      @actions = []

      self
    end

    def superclass_name_from_class_node(node)
      case node.superclass
      when Prism::ConstantPathNode
        node.superclass.child.name
      when Prism::ConstantReadNode
        node.superclass.name
      else
        "NSObject"
      end
    end
  end
end
