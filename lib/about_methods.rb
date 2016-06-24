## Methods used in the about view
module AboutMethods
  ## Creates the aboutme page
  def create_aboutme
    data = { posts: read_posts, sub_file: false }
    create_partials false, data
    system 'erb _templates/_aboutme.html.erb > aboutme.html'
  end

  ## Gets path to aboutme view depending on whether or not
  ## view in question is a sub_file
  def get_aboutme_path(sub_file)
    sub_file ? '../aboutme.html' : 'aboutme.html'
  end
end
