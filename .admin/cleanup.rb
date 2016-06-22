## Cleans
def clean_up(options = {})
  Dir.foreach('.') do |item|
    next if default_files.include?(item)
    next if item[0..3] == 'page' && !options[:page_folder]
    next if optional_candidates.include?(item) && !options[item]
    system "rm -rf #{item}"
  end
end

## Default files to not be deleted apon cleanup
def default_files
  %w(. .. .git .methods.rb bootstrap compile.rb css posts
     defaults.yml fonts index.html less README.md _templates
     methods.rb partial_methods.rb aboutme.html .admin .compile.rb
     .git post.rb)
end

## Files that are optionally deleted apon cleanup
def optional_candidates
  %w(articles archives.html)
end

## Options hash to delete optional_candidates
def pre_compile_clean_options
  { page_folder: true, 'articles' => true, 'archives.html' => true }
end
