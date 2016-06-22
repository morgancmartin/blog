#!/usr/bin/env ruby
require "yaml"
require_relative ".admin/methods"
options = {page_folder: true, articles_folder: true, archives_file: true}

clean_up options
compile_less
generate_articles
construct_archives
create_aboutme
create_indices
clean_up
