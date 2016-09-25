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

class Colorizer < Myhtml::SAX::IncomingTokenizer
  def on_token(token)
    # colorize_print2(token.pre_tag_slice, "\e[33m")
    # colorize_print2(token.tag_text_slice, "\e[32m")
    # colorize_print2(token.post_tag_slice, "\e[33m")

    p 1 if token.tag_sym == :a

    # case token.tag_sym
    # when :_doctype
    #   colorize_print2(token.pre_tag_slice, "\e[37m")
    #   colorize_print2(token.tag_name_slice, "\e[37m")
    #   colorize_print2(token.post_tag_slice, "\e[37m")
    # when :_text
    #   colorize_print2(token.tag_text_slice, "\e[0m")
    # when :_comment
    #   colorize_print2(token.pre_tag_slice, "\e[32m")
    #   colorize_print2(token.tag_name_slice, "\e[32m")
    #   colorize_print2(token.post_tag_slice, "\e[32m")

    #   colorize_print(inc_buf, token_element_pos.start, (token_pos.start - token_element_pos.start), "\e[32m")
    #   colorize_print(inc_buf, token_pos.start, token_pos.length, "\e[32m")
    #   colorize_print(inc_buf, last_pos, ((token_element_pos.start + token_element_pos.length) - last_pos), "\e[32m")
    # when :_end_of_file
    # else
    #   # colorize_print(inc_buf, token_element_pos.start, (token_pos.start - token_element_pos.start), "\e[31m")
    #   # p "-"
    #   # colorize_print(inc_buf, token_pos.start, token_pos.length, "\e[31m")
    #   # p "-"
    #   # # last_pos = colorize_print_attributes(token, inc_buf, last_pos)
    #   # colorize_print(inc_buf, last_pos, ((token_element_pos.start + token_element_pos.length) - last_pos), "\e[31m")
    #   # p "-"

    #   colorize_print2(token.pre_tag_slice, "\e[31m")
    #   colorize_print2(token.tag_name_slice, "\e[31m")
    #   colorize_print2(token.post_tag_slice, "\e[31m")
    # end
  end

  private def colorize_print(inc_buf, start, length, color)
    return unless length > 0

    inc_buf = Myhtml::Lib.incoming_buffer_find_by_position(inc_buf, start)

    between_start = (start - Myhtml::Lib.incoming_buffer_offset(inc_buf))
    between_data = Myhtml::Lib.incoming_buffer_data(inc_buf)

    between = String.new(between_data + between_start, length)

    print "#{color}#{between}\e[0m"
  end

  private def colorize_print2(slice, color)
    print "#{color}#{String.new(slice)}\e[0m"
  end

  private def colorize_print_attributes(token, inc_buf, last_pos)
    token.each_raw_attribute do |attr|
      key_pos = Myhtml::Lib.attribute_key_raw_position(attr)
      value_pos = Myhtml::Lib.attribute_value_raw_position(attr)

      if key_pos.length > 0
        if (last_pos < key_pos.start)
          colorize_print(inc_buf, last_pos, (key_pos.start - last_pos), "\e[31m")
          p "-1"
        end
        colorize_print(inc_buf, key_pos.start, key_pos.length, "\e[33m")
        p "-2"
        if ((key_pos.start + key_pos.length) > last_pos)
          last_pos = key_pos.start + key_pos.length
        end
      else
        if value_pos.length && last_pos < value_pos.start
          colorize_print(inc_buf, last_pos, (value_pos.start - last_pos), "\e[31m")
          p "-3"
        end
      end

      if (value_pos.length > 0)
        if (key_pos.length > 0)
          between_start = key_pos.start + key_pos.length
          colorize_print(inc_buf, between_start, (value_pos.start - between_start), "\e[31m")
          p "-4"
        end
        colorize_print(inc_buf, value_pos.start, value_pos.length, "\e[34m")
        p "-5"
        if (value_pos.start + value_pos.length > last_pos)
          last_pos = value_pos.start + value_pos.length
        end
      end
    end

    last_pos
  end
end

parser = Myhtml::SAX.new(Colorizer.new)
parser.parse(str)
puts

class Dd1 < Myhtml::SAX::Doc1
  def on_open_tag(token)
    p token.tag_sym
  end
end

class Dd2 < Myhtml::SAX::Doc2
  def on_open_tag(token)
    p token.tag_sym
  end
end

d1 = Dd1.new
d2 = Dd2.new

parser = Myhtml::SAX.new(d1)
parser.parse(str)
puts

parser = Myhtml::SAX.new(d2)
parser.parse(str)
puts
