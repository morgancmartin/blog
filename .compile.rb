#!/usr/bin/env ruby
require "yaml"
require_relative ".admin/methods"
options = {delete_page_folder: true}

clean_up options
create_partials
compile_less
data = {posts: get_posts, header: get_header, footer: get_footer}
create_indices data
clean_up
