# Example: colorize input html, without any change, with sax parser

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
          <html>
            <!-- comment -->
            <Div><span class='test'>HTML &amp; YYY</span></div><div Class=O>1</div>
          </html>
        HTML
      end

parser = Myhtml::SAX.new

def colorize_print(inc_buf, start, length, color)
  return unless length > 0

  inc_buf = Myhtml::Lib.incoming_buffer_find_by_position(inc_buf, start)

  between_start = (start - Myhtml::Lib.incoming_buffer_offset(inc_buf))
  between_data = Myhtml::Lib.incoming_buffer_data(inc_buf)

  between = String.new(between_data + between_start, length)

  print "#{color}#{between}\e[0m"
end

# def colorize_print_attributes(token, inc_buf, last_pos)
#   attr = Myhtml::Lib.token_node_attribute_first(token)
#   while !attr.null?
#     key_pos = Myhtml::Lib.attribute_key_raw_position(attr)
#     value_pos = Myhtml::Lib.attribute_value_raw_position(attr)

#     if key_pos.length > 0
#       if (last_pos < key_pos.start)
#         colorize_print(inc_buf, last_pos, (key_pos.start - last_pos), "\e[31m")
#       end
#       colorize_print(inc_buf, key_pos.start, key_pos.length, "\e[33m")
#       if ((key_pos.start + key_pos.length) > last_pos)
#         last_pos = key_pos.start + key_pos.length
#       end
#     else
#       if value_pos.length && last_pos < value_pos.start
#         colorize_print(inc_buf, last_pos, (value_pos.start - last_pos), "\e[31m")
#       end
#     end

#     if (value_pos.length > 0)
#       if (key_pos.length > 0)
#         between_start = key_pos.start + key_pos.length
#         colorize_print(inc_buf, between_start, (value_pos.start - between_start), "\e[31m")
#       end
#       colorize_print(inc_buf, value_pos.start, value_pos.length, "\e[34m")
#       if (value_pos.start + value_pos.length > last_pos)
#         last_pos = value_pos.start + value_pos.length
#       end
#     end

#     attr = Myhtml::Lib.attribute_next(attr)
#   end

#   last_pos
# end

callback = ->(token : Myhtml::Token) do
  buffer = Myhtml::IncomingBuffer.new(token.raw_tree)

  inc_buf = Myhtml::Lib.tree_incoming_buffer_first(token.raw_tree)
  to
  token_pos = Myhtml::Lib.token_node_raw_pasition(token)
  token_element_pos = Myhtml::Lib.token_node_element_pasition(token)

  last_pos = token_pos.start + token_pos.length

  case token.tag_sym
  when :_doctype
    colorize_print(inc_buf, token_element_pos.start, (token_pos.start - token_element_pos.start), "\e[37m")
    colorize_print(inc_buf, token_pos.start, token_pos.length, "\e[37m")
    colorize_print(inc_buf, last_pos, ((token_element_pos.start + token_element_pos.length) - last_pos), "\e[37m")
  when :_text
    colorize_print(inc_buf, token_pos.start, token_pos.length, "\e[0m")
  when :_comment
    colorize_print(inc_buf, token_element_pos.start, (token_pos.start - token_element_pos.start), "\e[32m")
    colorize_print(inc_buf, token_pos.start, token_pos.length, "\e[32m")
    colorize_print(inc_buf, last_pos, ((token_element_pos.start + token_element_pos.length) - last_pos), "\e[32m")
  else
    colorize_print(inc_buf, token_element_pos.start, (token_pos.start - token_element_pos.start), "\e[31m")
    printf("---")
    colorize_print(inc_buf, token_pos.start, token_pos.length, "\e[31m")
    printf("---")
    # last_pos = colorize_print_attributes(token, inc_buf, last_pos)
    colorize_print(inc_buf, last_pos, ((token_element_pos.start + token_element_pos.length) - last_pos), "\e[31m")
    printf("---")
  end
end

parser.parse(str, callback)
puts
