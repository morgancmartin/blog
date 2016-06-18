def clean_up
  defaults = %w[. .. .git .methods.rb bootstrap compile.rb css post
                defaults.yml fonts index.html less README.md _templates]
  Dir.foreach('.') do |item|
    next if defaults.include?(item) or item[0] == "." or item == "post"
    system "rm -rf #{item}"
  end
end

def write_data data, loc
  f = File.open(loc, "w+")
  f.puts(YAML.dump(data))
  f.rewind
end
