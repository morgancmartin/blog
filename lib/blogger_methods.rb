## General methods used through application
module BloggerMethods
  require 'yaml'

  ## Writes a data object to a given location for use in views
  ## NOTE: Data is never written anywhere besides main folder
  ## This needs refactoring.
  def write_data(data, loc, yaml=true)
    f = File.open(loc, 'w+')
    yaml ? f.puts(YAML.dump(data)) : f.puts(data)
    f.rewind
  end

  ## Reads data object and defaults file from main folder for use in view
  def read_data file='data'
    data = YAML.load(IO.read(file))
    defaults = YAML.load(IO.read('defaults.yml'))
    defaults.merge(data)
  end

  def read_file file
    File.open(file, "r").read
  end

  ## Creates an array of post-hash-objects with qualities
  ## derived from the file's contents
  def read_posts
    post_filenames = Dir['posts/*'].sort.reverse.map do |filename|
      chars = filename.split('')
      chars.shift(6)
      chars.join('')
    end
    post_filenames.map do |filename|
      Post.new(filename)
    end
  end

  ## Compile less file "styles.less"
  def compile_less
    system 'lessc -s less/styles.less css/styles.css'
  end

  ## Returns a string specifying stylesheet locations relative to a file's
  ## location
  def get_stylesheet_loc(sub_file)
    sub_file ? sub_file_stylesheet_locs : main_file_stylesheet_locs
  end

  ## Returns a string specifying stylesheet locations relative to
  ## a "sub_file" or file that is located one level below the main
  ## "blog" folder
  def sub_file_stylesheet_locs
    "<link href=\"#{bootstrap_cdn}\" rel=\"stylesheet\">
     <link href=\"../css/styles.css\" rel=\"stylesheet\">"
  end

  ## Returns a string specifying stylesheet locations relative to
  ## the main "blog" folder
  def main_file_stylesheet_locs
    "<link href=\"#{bootstrap_cdn}\" rel=\"stylesheet\">
     <link href=\"css/styles.css\" rel=\"stylesheet\">"
  end

  ## Link to bootstrap framework
  def bootstrap_cdn
    'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css'
  end

  ## Create partials with type according to "sub_file"
  def create_partials(sub_file, data)
    write_data data, 'data'
    if sub_file
      system 'erb _templates/_header.html.erb > sub_file_header.html'
      system 'erb _templates/_footer.html.erb > sub_file_footer.html'
    else
      system 'erb _templates/_header.html.erb > header.html'
      system 'erb _templates/_footer.html.erb > footer.html'
    end
  end

  ## Gets a path to header depending on whether view is a sub_file
  def get_header_path(sub_index)
    sub_index ? 'sub_file_header.html' : 'header.html'
  end

  ## Gets a path to footer depending on whether view is a sub_file
  def get_footer_path(sub_index)
    sub_index ? 'sub_file_footer.html' : 'footer.html'
  end

  ## Constructs a file path for a file. If it's a sub file it
  ## does so in an "upwards" manner.
  def construct_path_upwards(sub_file, path)
    sub_file ? "../#{path}" : path
  end

  ## Constructs a file path for a file. If it's a sub file it
  ## does so in an "downwards" manner.
  def construct_path_downwards(sub_file, file)
    sub_file ? "#{path}/" : file
  end
end
