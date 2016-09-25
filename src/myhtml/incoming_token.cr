require "./tag_id_utils"

module Myhtml
  struct IncomingToken
    include TagIdUtils

    @attributes : Hash(String, String)?

    getter raw_tree, raw_token

    def self.from_raw(raw_tree, raw_token) : IncomingToken?
      unless raw_token.null?
        Token.new(raw_tree, raw_token)
      end
    end

    getter buffer : Lib::MyhtmlIncomingBufferT*

    def initialize(@raw_tree : Lib::MyhtmlTreeT*, @raw_token : Lib::MyhtmlTokenNodeT*)
      @buffer = Lib.tree_incoming_buffer_first(@raw_tree)
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
      pos_to_slice raw_position
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
      each_raw_attribute do |attr|
        key = AttrKey.new(pos_to_slice(attr_key_pos(attr)))
        value = pos_to_slice(attr_value_pos(attr))
        yield key, value
      end
    end

    record AttrKey, name : Bytes do
      forward_missing_to @name

      def hash
        h = 0
        name.each_byte do |c|
          c = normalize_byte(c)
          h = 31 * h + c
        end
        h
      end

      def to_s
        String.build(name.bytesize) do |buf|
          # appender = buf.appender
          name.each do |byte|
            buf << normalize_byte(byte)
          end
          {name.bytesize, name.bytesize}
        end
      end

      def ==(key2)
        key1 = name
        key2 = key2.name

        return false if key1.bytesize != key2.bytesize

        cstr1 = key1.to_unsafe
        cstr2 = key2.to_unsafe

        key1.bytesize.times do |i|
          next if cstr1[i] == cstr2[i] # Optimize the common case

          byte1 = normalize_byte(cstr1[i])
          byte2 = normalize_byte(cstr2[i])

          return false if byte1 != byte2
        end
      end

      private def normalize_byte(byte)
        char = byte.unsafe_chr

        return byte if char.lowercase? || char == '-' # Optimize the common case
        return byte + 32 if char.uppercase?
        return '-'.ord if char == '_'

        byte
      end
    end

    def attribute_by(string : String)
      kk = AttrKey.new(string.to_slice)
      each_attribute do |k, v|
        return String.new(v) if k == kk
      end
    end

    def attribute_by(slice : Slice(UInt8))
      kk = AttrKey.new(slice)
      each_attribute do |k, v|
        return v if k == kk
      end
    end

    def attributes
      @attributes ||= begin
        res = {} of String => String
        each_attribute do |k, v|
          res[k.to_s] = String.new(v)
        end
        res
      end
    end

    def pre_tag_slice
      rp = raw_position
      ep = element_position
      pos_to_slice(ep.start, rp.start - ep.start)
    end

    def post_tag_slice
      rp = raw_position
      ep = element_position
      pos_to_slice(rp.start + rp.length, ep.start + ep.length - (rp.start + rp.length))
    end

    def raw_position
      Myhtml::Lib.token_node_raw_pasition(@raw_token)
    end

    def element_position
      Myhtml::Lib.token_node_element_pasition(@raw_token)
    end

    private def attr_key_pos(attr)
      Myhtml::Lib.attribute_key_raw_position(attr)
    end

    private def attr_value_pos(attr)
      Myhtml::Lib.attribute_value_raw_position(attr)
    end

    def pos_to_slice(start, size)
      buf = Myhtml::Lib.incoming_buffer_find_by_position(buffer, start)
      between_start = (start - Myhtml::Lib.incoming_buffer_offset(buf))
      between_data = Myhtml::Lib.incoming_buffer_data(buf)
      Slice.new(between_data + between_start, size)
    end

    private def pos_to_slice(pos)
      pos_to_slice(pos.start, pos.length)
    end
  end
end
