def get_data
  data = YAML.load(File.open("data"))
  defaults = YAML.load(File.open("defaults.yml"))
  post = YAML.load(File.open("post"))
  defaults.merge(data).merge(post)
end
