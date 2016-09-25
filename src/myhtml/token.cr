module Myhtml
  struct Token
    include TagIdUtils

    @attributes : Hash(String, String)?

    getter raw_tree, raw_token

    def self.from_raw(raw_tree, raw_token) : Token?
      unless raw_token.null?
        Token.new(raw_tree, raw_token)
      end
    end

    def initialize(@raw_tree : Lib::MyhtmlTreeT*, @raw_token : Lib::MyhtmlTokenNodeT*)
    end

    def self_closed?
      Lib.token_node_is_close_self(@raw_token)
    end

    def closed?
      Lib.token_node_is_close(@raw_token)
    end

    def tag_id
      Lib.token_node_tag_id(@raw_token)
    end

    def tag_name_slice
      res = Lib.tag_name_by_id(@raw_tree, tag_id, out length)
      Slice.new(res, length)
    end

    def tag_name
      String.new(tag_name_slice)
    end

    def tag_text_slice
      res = Lib.token_node_text(@raw_token, out length)
      Slice.new(res, length)
    end

    def tag_text
      String.new(tag_text_slice)
    end

    def each_raw_attribute(&block)
      attr = Lib.token_node_attribute_first(@raw_token)
      while !attr.null?
        yield attr
        attr = Lib.attribute_next(attr)
      end
    end

    def each_attribute(&block)
      name_length = LibC::SizeT.new(0)
      value_length = LibC::SizeT.new(0)
      each_raw_attribute do |attr|
        name = Lib.attribute_key(attr, pointerof(name_length))
        value = Lib.attribute_value(attr, pointerof(value_length))
        name_slice = Slice(UInt8).new(name, name_length)
        value_slice = Slice(UInt8).new(value, value_length)
        yield name_slice, value_slice
      end
    end

    def attribute_by(string : String)
      each_attribute do |k, v|
        return String.new(v) if k == string.to_slice
      end
    end

    def attribute_by(slice : Slice(UInt8))
      each_attribute do |k, v|
        return v if k == slice
      end
    end

    def attributes
      @attributes ||= begin
        res = {} of String => String
        each_attribute do |k, v|
          res[String.new(k)] = String.new(v)
        end
        res
      end
    end
  end
end
