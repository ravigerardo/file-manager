require 'rbconfig'

require_relative 'main-window'

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

FileManager.new(os: os).launch
