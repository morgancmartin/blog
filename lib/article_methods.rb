## Methods used in Article Views
module ArticleMethods
  ## Generates an article page for each post supplied in "posts" folder
  def generate_articles
    system 'mkdir articles'
    read_posts.each { |post| generate_article post }
  end

  ## Generates an article page for a supplied post object
  def generate_article(post)
    create_partials true, read_data
    header = read_file(get_header_path(true))
    footer = read_file(get_footer_path(true))
    data = { post: post, sub_file: true, header: header, footer: footer }
    write_data data, 'data'
    system "erb _templates/_article.html.erb > articles/#{post.filename}"
  end
end
