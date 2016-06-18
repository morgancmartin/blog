def get_data
  data = YAML.load(IO.read("data"))
  defaults = YAML.load(IO.read("defaults.yml"))
  defaults.merge(data)
end
