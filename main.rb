require 'rbconfig'

require_relative 'state'
require_relative 'main_window'

home_path = `realpath ~`.chop
os = nil

case RbConfig::CONFIG['host_os']
when /darwin|mac os/
  puts "Running on macOS"
  os = :macos
when /linux/
  puts "Running on Linux"
  os = :linux
else
  abort "Unknown OS: #{RbConfig::CONFIG['host_os']}"
end

AppState.instance.set_state(os: os, home_path: home_path)
FileManager.new.launch
