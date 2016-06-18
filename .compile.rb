#!/usr/bin/env ruby
require "yaml"
require_relative ".admin/methods"

clean_up
data = {thing: "thing", other: "stuff", and: "again"}
write_data data, "data"

system "mkdir .admin/_partials"
system "erb _templates/_header.html.erb > .admin/_partials/header.html"
system "erb _templates/_footer.html.erb > .admin/_partials/footer.html"
system "lessc less/styles.less css/styles.css"
system "erb _templates/_index.html.erb > index.html"
clean_up
