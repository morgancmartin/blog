def write_data data, loc
  f = File.open(loc, "w+")
  f.puts(YAML.dump(data))
  f.rewind
end

def clean_up options = {delete_page_folder: false}
  defaults = %w[. .. .git .methods.rb bootstrap compile.rb css posts
                defaults.yml fonts index.html less README.md _templates
                methods.rb partial_methods.rb]
  Dir.foreach(".") do |item|
    next if defaults.include?(item) or item[0] == "."
    next if item[0..3] == "page" && (options[:delete_page_folder] == false)
    system "rm -rf #{item}"
  end
  Dir.foreach(".admin/") do |item|
    next if defaults.include?(item)
    system "rm -rf .admin/#{item}"
  end
end

def find_post_content post, match, close_length
  lines = post.split("\n")
  length = (match.length - 1)
  lines.each do |line|
    if line[0..length] == match
      chars = line.split("")
      chars.shift(match.length)
      chars.pop(close_length)
      return chars.join("")
    end
  end
  false
end

def get_post_title post
  find_post_content post, "<h1>", 5
end

#<p class="date"> 16
def get_post_date post
  find_post_content post, '<p class="date">', 4
end

def get_post_year post
  if get_post_date(post)
    chars = get_post_date(post).split("")
    return chars.pop(4).join("")
  end
end

def get_posts
  posts = Dir["posts/*"].sort.reverse
  posts.map do |post|
    filename = post.split("")
    filename.shift(6)
    filename = filename.join("")
    contents = File.open("posts/#{filename}", "r").read
    {filename: filename, filecontents: contents,
     title: get_post_title(contents), date: get_post_date(contents),
     year: get_post_year(contents)}
  end
end

def system_announce message, data
  puts message
  puts data.inspect
end

def sub_folder_stylesheet_locs
  '<link href="../bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="../css/styles.css" rel="stylesheet"> '
end

def main_folder_stylesheet_locs
  '    <link href="bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="css/styles.css" rel="stylesheet">'
end

def get_header
  @header = File.open(".admin/_partials/header.html", "r").read
end

def get_footer
  File.open(".admin/_partials/footer.html", "r").read
end

def create_index data, folder_num
  start = ((folder_num - 1) * 4)
  last = start + 3
  data[:start] = start
  data[:last] = last
  if folder_num > 1
    data[:stylesheetloc] = sub_folder_stylesheet_locs
    system "mkdir page#{folder_num}"
    write_data data, "data"
    system "erb _templates/_index.html.erb > page#{folder_num}/index.html"
  else
    data[:stylesheetloc] = main_folder_stylesheet_locs
    write_data data, "data"
    system "erb _templates/_index.html.erb > index.html"
  end
end

def create_indices data
  num_of_posts = data[:posts].length
  count = 0
  sub_index = 1
  while count < num_of_posts
    create_index data, sub_index
    count += 4
    sub_index += 1
  end
end

def create_partials
  data = {posts: get_posts}
  write_data data, "data"
  system "mkdir .admin/_partials"
  system "erb _templates/_header.html.erb > .admin/_partials/header.html"
  system "erb _templates/_footer.html.erb > .admin/_partials/footer.html"
end

def get_data
  data = YAML.load(IO.read("data"))
  defaults = YAML.load(IO.read("defaults.yml"))
  defaults.merge(data)
end

def compile_less
  system "lessc less/styles.less css/styles.css"
end
