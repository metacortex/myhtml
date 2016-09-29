module Myhtml
  class SAX
    abstract class Tokenizer
      abstract def on_token(token : Token)

      def on_start; end

      def on_done; end
    end

    abstract class IncomingTokenizer
      abstract def on_token(token : IncomingToken)

      def on_start; end

      def on_done; end
    end

    module HtmlFixer
      def on_token(token : Token | IncomingToken)
        case token.tag_id
        when Lib::MyhtmlTags::MyHTML_TAG__TEXT
          on_text(token.tag_text_slice)
        when Lib::MyhtmlTags::MyHTML_TAG__COMMENT
          on_comment(token.tag_text_slice)
        when Lib::MyhtmlTags::MyHTML_TAG__DOCTYPE
          on_doctype(token.attributes)
        when Lib::MyhtmlTags::MyHTML_TAG__END_OF_FILE
          on_finish
        else
          if token.closed?
            on_close_tag(token)
          else
            on_open_tag(token)
          end
        end
      end

      def on_open_tag(token : Token | IncomingToken)
      end

      def on_close_tag(token : Token | IncomingToken)
      end

      def on_text(text : Bytes)
      end

      def on_finish
      end

      def on_comment(text : Bytes)
      end

      def on_script(text : Bytes)
      end

      def on_doctype(attrs)
      end
    end

    class Doc1 < Tokenizer
      include HtmlFixer
    end

    class Doc2 < IncomingTokenizer
      include HtmlFixer
    end

    class Document < Tokenizer
      def on_open_tag(token : Token)
      end

      def on_close_tag(token : Token)
      end

      def on_text(text : Bytes)
      end

      def on_finish
      end

      def on_comment
      end

      def on_doctype(attrs)
      end

      def on_token(token : Token)
        case token.tag_id
        when Lib::MyhtmlTags::MyHTML_TAG__TEXT
          on_text(token.tag_text_slice)
        when Lib::MyhtmlTags::MyHTML_TAG__COMMENT
          on_comment
        when Lib::MyhtmlTags::MyHTML_TAG__DOCTYPE
          on_doctype(token.attributes)
        when Lib::MyhtmlTags::MyHTML_TAG__END_OF_FILE
          on_finish
        else
          if token.closed?
            on_close_tag(token)
          else
            on_open_tag(token)
          end
        end
      end
    end

    @tokenizer : Tokenizer | IncomingTokenizer
    @string : String?

    def initialize(@tokenizer : Tokenizer | IncomingTokenizer | Array(Tokenizer) | Array(IncomingTokenizer), options = Lib::MyhtmlOptions::MyHTML_OPTIONS_DEFAULT, threads_count = 1, queue_size = 0, tree_options = nil)
      tree_options ||= if @tokenizer.is_a?(IncomingTokenizer)
                         Lib::MyhtmlTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_WITHOUT_PROCESS_TOKEN
                       else
                         Lib::MyhtmlTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_WITHOUT_BUILD_TREE
                       end

      @tree = Tree.new(options, threads_count, queue_size, tree_options: tree_options)
    end

    # Dangerous, free object
    def free
      @tree.free
    end

    CALLBACK = ->(_tree : Myhtml::Lib::MyhtmlTreeT*, _token : Myhtml::Lib::MyhtmlTokenNodeT*, _ctx : Void*) do
      unless _ctx.null?
        tok = _ctx.as Tokenizer

        unless _token.null?
          tok.on_token(Token.new(_tree, _token))
        end
      end

      _ctx
    end

    CALLBACKS = ->(_tree : Myhtml::Lib::MyhtmlTreeT*, _token : Myhtml::Lib::MyhtmlTokenNodeT*, _ctx : Void*) do
      unless _ctx.null?
        toks = _ctx.as Array(Tokenizer)

        unless _token.null?
          t = Token.new(_tree, _token)
          toks.each &.on_token(t)
        end
      end

      _ctx
    end

    INCOMING_CALLBACK = ->(_tree : Myhtml::Lib::MyhtmlTreeT*, _token : Myhtml::Lib::MyhtmlTokenNodeT*, _ctx : Void*) do
      unless _ctx.null?
        tok = _ctx.as IncomingTokenizer

        unless _token.null?
          tok.on_token(IncomingToken.new(_tree, _token))
        end
      end

      _ctx
    end

    INCOMING_CALLBACKS = ->(_tree : Myhtml::Lib::MyhtmlTreeT*, _token : Myhtml::Lib::MyhtmlTokenNodeT*, _ctx : Void*) do
      unless _ctx.null?
        toks = _ctx.as Array(IncomingTokenizer)

        unless _token.null?
          t = IncomingToken.new(_tree, _token)
          toks.each &.on_token(t)
        end
      end

      _ctx
    end

    def parse(@string, encoding = Lib::MyhtmlEncodingList::MyHTML_ENCODING_UTF_8)
      pointer = string.to_unsafe
      bytesize = string.bytesize

      if Lib.encoding_detect_and_cut_bom(pointer, bytesize, out encoding2, out pointer2, out bytesize2)
        pointer = pointer2
        bytesize = bytesize2
        encoding = encoding2
      end

      if (t = @tokenizer)
        if t.is_a?(Array)
          @tokenizer.each &.on_start
        else
          @tokenizer.on_start
        end
      end

      cb = case @tokenizer
           when Tokenizer
             CALLBACK
           when Array(Tokenizer)
             CALLBACKS
           when IncomingTokenizer
             INCOMING_CALLBACK
           when Array(IncomingTokenizer)
             INCOMING_CALLBACKS
           else
             raise "unknown tokenizer type"
           end
      Lib.callback_after_token_done_set(@tree.raw_tree, cb, @tokenizer.as(Void*))

      res = Lib.parse(@tree.raw_tree, encoding, pointer, bytesize)
      raise Error.new("parse error #{res}") if res != Lib::MyhtmlStatus::MyHTML_STATUS_OK

      if (t = @tokenizer)
        if t.is_a?(Array)
          @tokenizer.each &.on_done
        else
          @tokenizer.on_done
        end
      end

      self
    end
  end
end
