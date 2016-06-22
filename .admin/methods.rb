@vars = {}

def default_files
  %w[. .. .git .methods.rb bootstrap compile.rb css posts
     defaults.yml fonts index.html less README.md _templates
     methods.rb partial_methods.rb aboutme.html .admin .compile.rb
     .git]
end

def clean_up options = {}
  optionals = %w[articles archives.html]
  Dir.foreach(".") do |item|
    next if default_files.include?(item)
    next if item[0..3] == "page" && !options[:page_folder]
    next if optionals.include?(item) && !options[item]
    system "rm -rf #{item}"
  end
end

def pre_compile_clean_options
  options = {page_folder: true, "articles" => true, "archives.html"=> true}
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

def get_stylesheet_loc sub_file
  sub_file ? sub_folder_stylesheet_locs : main_folder_stylesheet_locs
end

def get_header
  File.open("header.html", "r").read
end

def get_footer
  File.open("footer.html", "r").read
end

def create_partials sub_file, data
  write_data data, "data"
  if sub_file
    system "erb _templates/_header.html.erb > sub_file_header.html"
    system "erb _templates/_footer.html.erb > sub_file_footer.html"
  else
    system "erb _templates/_header.html.erb > header.html"
    system "erb _templates/_footer.html.erb > footer.html"
  end
end

def compile_less
  system "lessc less/styles.less css/styles.css"
end

def shorten_post_contents contents
  return contents if contents.length < 1500
  splits = contents.split("\n")
  while splits.join('').length > 1500
    splits.pop
  end
  splits.pop if splits[-1][0..1] == "<h"
  splits.join("\n")
end

def pagination_list_item_class index_number, page
  index_number == page ? "page-item active" : "page-item"
end

def sr_span index_number, page
  index_number == page ? '<span class="sr-only">(current)</span>' : ""
end

def calc_num_of_indices num_of_posts
  remainder = (num_of_posts % 4 > 0)
  remainder ? num_of_posts / 4 + 1 : num_of_posts / 4
end

def pagination_href index_number, page, num_of_indices
  return "index.html" if index_number == page && page == 1
  return "index.html" if index_number == 1 and page == "previous"
  return "../page#{num_of_indices}/index.html" if index_number == num_of_indices and page == "next"
  return pagination_href(index_number, index_number - 1, num_of_indices) if page == "previous"
  return pagination_href(index_number, index_number + 1, num_of_indices) if page == "next"
  return "../index.html" if page == 1 and index_number > page
  return "page#{page}/index.html" if index_number == 1 and page <= num_of_indices
  return "page#{num_of_indices}/index.html" if index_number == 1 and page > num_of_indices
  return "../page#{page}/index.html" if page <= num_of_indices
  return "../page#{num_of_indices}/index.html"
end

def create_index data, folder_num
  if folder_num > 1
    data[:stylesheetloc] = sub_folder_stylesheet_locs
    system "mkdir page#{folder_num}"
    create_partials data[:sub_file], data
    write_data data, "data"
    system "erb _templates/_index.html.erb > page#{folder_num}/index.html"
  else
    create_partials data[:sub_file], data
    data[:stylesheetloc] = main_folder_stylesheet_locs
    write_data data, "data"
    system "erb _templates/_index.html.erb > index.html"
  end
end

def format_contents data
  posts = data[:posts]
  contents = posts.map do |post|
    link_header_to_article(post[:filecontents], post[:filename], data[:sub_file])
  end
  contents.map! do |content|
    shorten_post_contents content
  end
end

def link_header_to_article contents, filename, sub_file
  splits = contents.split("\n")
  splits[0] = linkify_header splits[0], filename, sub_file
  splits.join("\n")
end

def linkify_header header, filename, sub_file
  href = sub_file ? "../articles/#{filename}" : "articles/#{filename}"
  "<a href=\"#{href}\">" + header + "</a>"
end

def add_post_info data, folder_num
  start = ((folder_num - 1) * 4)
  last = start + 3
  data[:start] = start
  data[:last] = last
  data[:folder_num] = folder_num
  data[:sub_file] = folder_num > 1
  data[:formattedcontents] = format_contents(data)
  data[:indextotal] = calc_num_of_indices(data[:posts].length)
end

def create_indices
  data = {posts: get_posts}
  count = 0
  folder_num = 1
  while count < data[:posts].length
    add_post_info data, folder_num
    create_index data, folder_num
    count += 4
    folder_num += 1
  end
end

def get_header_path sub_index
  sub_index ? "sub_file_header.html" : "header.html"
end

def get_footer_path sub_index
  sub_index ? "sub_file_footer.html" : "footer.html"
end

def write_data data, loc
  f = File.open(loc, "w+")
  f.puts(YAML.dump(data))
  f.rewind
end

def get_data
  data = YAML.load(IO.read("data"))
  defaults = YAML.load(IO.read("defaults.yml"))
  defaults.merge(data)
end

def generate_articles
  system "mkdir articles"
  get_posts.each{|post| generate_article post}
end

def generate_article post
  data = {post: post, sub_file: true}
  create_partials true, data
  write_data data, "data"
  system "erb _templates/_article.html.erb > articles/#{post[:filename]}"
end

def construct_path_upwards sub_file, path
  sub_file ? "../#{path}" : path
end

def construct_path_downwards sub_file, file
  sub_file ? "#{path}/" : file
end

def format_date date
  chars = date.split("")
  chars.pop(6)
  chars.join("")
end

def link_title_to_article title, filename
  "<a href=\"articles/#{filename}\">" + title + "</a>"
end

def archives_year_header year, last_iter
  return nil if year == last_iter
  return "This year" if year == Time.now.year
  return "Last year" if year == (Time.now.year - 1)
  year
end

def get_archives_path sub_file
  sub_file ? "../archives.html" : "archives.html"
end

def construct_archives
  data = {posts: get_posts, sub_file: false}
  create_partials false, data
  data[:posts].each do |post|
    post[:formatteddate] = format_date(post[:date])
    post[:linked_title] = link_title_to_article post[:title], post[:filename]
  end
  write_data data, "data"
  system "erb _templates/_archives.html.erb > archives.html"
end

def get_aboutme_path sub_file
  sub_file ? "../aboutme.html" : "aboutme.html"
end

def create_aboutme
  data = {posts: get_posts, sub_file: false}
  create_partials false, data
  system "erb _templates/_aboutme.html.erb > aboutme.html"
end

#Different templates have different links depending on their location.
#Sub Indexes have different urls than the main Index
#Headers and Footers have different links depending on the type of Index
#Links to articles from the index vary on the type of index.

#SubFiles = All Articles, All sub-Indexes, Sub-index/article headers/footers
#Non-Subs = Main Index, Archives, Main-Index/Archive Headers/footers
#As it is currently, I am creating all headers/footers from the main-index perspective.
#
