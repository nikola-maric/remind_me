# frozen_string_literal: true

require 'mkmf'

if system('cargo --version > /dev/null 2>&1')
  require 'rb_sys/mkmf'
  create_rust_makefile('remind_me/remind_me_native')
else
  File.write('Makefile', "all:\ninstall:\n")
  $stderr.puts 'WARNING: Rust toolchain not found, skipping native extension build. Using pure-Ruby fallback.'
end