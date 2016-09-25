# Example: find tags

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

s = 0

t = Time.now
1.times do
  parser = Myhtml::Parser.new
  parser.parse(str)
  s += parser.nodes(:a).count
  parser.free
end
p s
p Time.now - t

# parser.nodes(:a).each do |node|
#   p node.tag_name
#   p node.attributes
# end
