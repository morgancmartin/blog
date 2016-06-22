#!/usr/bin/env ruby
require "yaml"
require_relative ".admin/methods"
clean_up pre_compile_clean_options
compile_less
generate_articles
construct_archives
create_aboutme
create_indices
clean_up
