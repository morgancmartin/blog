## Constructs the archives page
def construct_archives
  data = { posts: read_posts, sub_file: false }
  create_partials false, data
  write_data data, 'data'
  system 'erb _templates/_archives.html.erb > archives.html'
end

## Creates a header based on year for use in archives view
def archives_year_header(year, last_iter)
  return nil if year == last_iter
  return 'This year' if year == Time.now.year
  return 'Last year' if year == (Time.now.year - 1)
  year
end

## Gets the archives path depending on view in question is a
## sub_file
def get_archives_path(sub_file)
  sub_file ? '../archives.html' : 'archives.html'
end
