require_relative 'methods'
## Post Object Model Class
class Post
  attr_reader :filename, :file_contents, :title, :date, :year, :linked_title,
              :formatted_date, :contents_w_code
  def initialize(filename)
    @filename = filename
    @file_contents = post_file_contents
    @title = post_title
    @date = post_date
    @year = post_year
    @linked_title = link_title_to_article
    @formatted_date = format_date
    @contents_w_code = replace_code_blocks(@file_contents)
  end

  def preview(sub_index)
    contents = linked_header_contents(sub_index)
    contents = shorten_post_contents(contents)
    replace_code_blocks(contents)
  end

  private

  ## Links an article's title to it's corresponding article view
  ## for use in archives view
  def link_title_to_article
    "<a href=\"articles/#{@filename}\">" + @title + '</a>'
  end

  ## Removes the year from the end of a date for use in archives view
  def format_date
    chars = @date.split('')
    chars.pop(6)
    chars.join('')
  end

  ## Wraps a post's header in a link to the matching article page
  def linked_header_contents(sub_file)
    splits = @file_contents.split("\n")
    splits[0] = linkify_header(splits[0], sub_file)
    splits.join("\n")
  end

  ## Wraps a post's header in a link to the matching article page
  def linkify_header(header, sub_file)
    href = sub_file ? "../articles/#{@filename}" : "articles/#{@filename}"
    "<a href=\"#{href}\">" + header + '</a>'
  end

  ## Shorten a post's contents to less than 1500 chars. Do not
  ## end this "preview" with a a header
  def shorten_post_contents(contents)
    return contents if contents.length < 1500
    splits = contents.split("\n")
    splits.pop while splits.join('').length > 1500
    splits.pop if splits[-1][0..1] == '<h'
    splits.join("\n")
  end

  ## Gets a post's file contents by filename
  def post_file_contents
    File.open("posts/#{@filename}", 'r').read
  end

  ## Gets post title
  def post_title
    find_post_content @file_contents, '<h1>', 5
  end

  ## Gets post publish date
  def post_date
    find_post_content @file_contents, '<p class="date">', 4
  end

  ## Gets post publish year
  def post_year
    chars = @date.split('')
    chars.pop(4).join('').to_i
  end

  def replace_code_blocks(contents)
    info = find_post_content_block(contents, '<p class="code">', '</p>')
    while info
      formatted_block = pygment_code_block(info[:block])
      contents = contents.split("\n")
      contents[info[:front]..info[:back]] = formatted_block
      contents = contents.join("\n")
      info = find_post_content_block(contents, '<p class="code">', '</p>')
    end
    contents
  end

  def pygment_code_block(block)
    write_data block, 'code.rb', false
    system 'pygmentize -o block.html code.rb'
    File.open('block.html', 'r').read
  end

  ## Finds a line starting with given "match" string.
  ## Removes html "match" length from front of line and
  ## html "close_length" from end of line.
  def find_post_content(file_contents, match, close_length)
    lines = file_contents.split("\n")
    length = (match.length - 1)
    lines.each do |line|
      next unless line[0..length] == match
      chars = line.split('')
      chars.shift(match.length)
      chars.pop(close_length)
      return chars.join('')
    end
    false
  end

  def find_post_content_block(file_contents, match_front, match_end)
    lines = file_contents.split("\n")
    length = (match_front.length - 1)
    front = nil
    back = nil
    lines.each_with_index do |line, index|
      next unless line[0..length] == match_front
      front = index
      break
    end
    length = (match_end.length - 1)
    lines.each_with_index do |line, index|
      next unless line[0..length] == match_end
      back = index
      break
    end
    block = lines[(front + 1)..(back - 1)].join("\n") if front && back
    info = { front: front, back: back, block: block }
    front && back ? info : false
  end
end
