# Example: count links in html with sax parser

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
          <div>
            <a class=Lba>Link1</a>
          </div>
        HTML
      end

class Doc < Myhtml::SAX::Tokenizer
  getter counter

  def initialize
    @counter = 0
  end

  def on_token(t)
    @counter += 1 if t.tag_id == Myhtml::Lib::MyhtmlTags::MyHTML_TAG_A
  end
end

s = 0
t = Time.now
20.times do
  parser = Myhtml::SAX.new
  doc = Doc.new
  parser.parse(str, doc)
  s += doc.counter
  parser.free
end
p s
p Time.now - t
