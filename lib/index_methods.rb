## Creates indices at 4 article previews per index
def create_indices
  data = { posts: read_posts }
  count = 0
  folder_num = 1
  while count < data[:posts].length
    add_post_info data, folder_num
    create_index data, folder_num
    count += 4
    folder_num += 1
  end
end

## Creates an index depending on whether it's a sub or main index
def create_index(data, folder_num)
  folder_num > 1 ? create_sub_index(data, folder_num) : create_main_index(data)
end

## Creates main index with supplied data for use in view
def create_main_index(data)
  create_partials data[:sub_file], data
  data[:stylesheetloc] = main_file_stylesheet_locs
  write_data data, 'data'
  system 'erb _templates/_index.html.erb > index.html'
end

## Creates sub index with supplied data for use in view
def create_sub_index(data, folder_num)
  data[:stylesheetloc] = sub_file_stylesheet_locs
  system "mkdir page#{folder_num}"
  create_partials data[:sub_file], data
  write_data data, 'data'
  system "erb _templates/_index.html.erb > page#{folder_num}/index.html"
end

## Adds relevant post information to the data object for use in the view
def add_post_info(data, folder_num)
  start = ((folder_num - 1) * 4)
  last = start + 3
  data[:start] = start
  data[:last] = last
  data[:folder_num] = folder_num
  data[:sub_file] = folder_num > 1
  data[:indextotal] = calc_num_of_indices(data[:posts].length)
end

## Calculates the num_of_indices at 4 posts per index
def calc_num_of_indices(num_of_posts)
  remainder = (num_of_posts % 4 > 0)
  remainder ? num_of_posts / 4 + 1 : num_of_posts / 4
end
