def clean_up
  defaults = %w[. .. .git .methods.rb bootstrap compile.rb css post
                defaults.yml fonts index.html less README.md _templates
                methods.rb partial_methods.rb]
  Dir.foreach('.') do |item|
    next if defaults.include?(item) or item[0] == "."
    system "rm -rf #{item}"
  end
  Dir.foreach('.admin/') do |item|
    next if defaults.include?(item)
    system "rm -rf .admin/#{item}"
  end
end

def write_data data, loc
  f = File.open(loc, "w+")
  f.puts(YAML.dump(data))
  f.rewind
end
