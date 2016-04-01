module Myhtml
  struct RightIterator
    include Iterator(Node)

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = next_to(@current_node.not_nil!)

      if cn = @current_node
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node
      self
    end

    private def next_to(node)
      node.child || node.next || next_parent(node)
    end

    private def next_parent(node)
      if parent = node.parent
        parent.next || next_parent(parent)
      end
    end
  end

  struct LeftIterator
    include Iterator(Node)

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = next_to(@current_node.not_nil!)

      if (cn = @current_node) && (cn.tag_id != Lib::MyhtmlTags::MyHTML_TAG__UNDEF)
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node
      self
    end

    private def next_to(node)
      if prev = node.prev
        deep_child(prev)
      else
        node.parent
      end
    end

    private def deep_child(node)
      if child = node.last_child
        deep_child(child)
      else
        node
      end
    end
  end

  struct ChildrenIterator
    include Iterator(Node)

    def initialize(@start_node : Node)
      rewind
    end

    def next
      if cn = @current_node
        @current_node = cn.next
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node.child
    end
  end

  struct ParentsIterator
    include Iterator(Node)

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = @current_node.not_nil!.parent
      if (cn = @current_node) && (cn.tag_id != Lib::MyhtmlTags::MyHTML_TAG__UNDEF)
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node
    end
  end

  struct EachTagIterator
    include Iterator(Node)

    def initialize(@tree, @tag_id)
      @tag_index = Lib.tree_get_tag_index(@tree.raw_tree)
    end

    def next
      return stop if @index_node.null?

      node = Lib.tag_index_tree_node(@index_node)
      if node.null?
        stop
      else
        node = Node.from_raw(@tree, node).not_nil!
        @index_node = Lib.tag_index_next(@index_node)
        node
      end
    end

    def rewind
      @index_node = Lib.tag_index_first(@tag_index, @tag_id)
    end
  end
end
