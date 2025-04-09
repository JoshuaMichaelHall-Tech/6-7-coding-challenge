#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Uninstall Script
# Removes all challenge scripts and configuration

require 'fileutils'
require_relative 'lib/cc_config'

# Load configuration
CONFIG = CCConfig.load

# Constants
HOME_DIR = ENV['HOME']
BIN_DIR = CCConfig.bin_dir
BASE_DIR = CCConfig.base_dir
CONFIG_FILE = File.join(HOME_DIR, '.cc-config.json')
DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
ZSHRC_FILE = File.join(HOME_DIR, '.zshrc')

# ANSI color codes
RESET = "\e[0m"
BOLD = "\e[1m"
GREEN = "\e[32m"
YELLOW = "\e[33m"
BLUE = "\e[34m"
RED = "\e[31m"

# Helper for colorized output
def colorize(text, color_code)
  return text unless CCConfig.use_colors?
  "#{color_code}#{text}#{RESET}"
end

# Parse command line arguments
require 'optparse'

options = {
  force: false,
  verbose: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ccuninstall [options]"
  
  opts.on("-f", "--force", "Force uninstall without prompts") do
    options[:force] = true
  end
  
  opts.on("-v", "--verbose", "Show verbose output") do
    options[:verbose] = true
  end
end.parse!

# Display header
puts colorize("6/7 Coding Challenge Uninstaller", BOLD)
puts "=" * 60
puts

# Confirm uninstallation
unless options[:force]
  print "Are you sure you want to uninstall the 6/7 Coding Challenge? (y/n): "
  response = STDIN.gets.strip.downcase
  unless response == 'y' || response == 'yes'
    puts colorize("Uninstallation canceled.", BLUE)
    exit 0
  end
end

# Remove scripts
puts colorize("Removing scripts...", BLUE)
script_count = 0
Dir.glob(File.join(BIN_DIR, "cc-*.rb")).each do |script|
  if File.exist?(script)
    File.delete(script)
    puts "  Deleted: #{script}" if options[:verbose]
    script_count += 1
  end
end
puts colorize("#{script_count} scripts removed.", GREEN) if script_count > 0

# Remove lib directory if it exists
lib_dir = File.join(BIN_DIR, 'lib')
if Dir.exist?(lib_dir)
  FileUtils.rm_rf(lib_dir)
  puts colorize("Removed lib directory: #{lib_dir}", GREEN)
end

# Remove aliases from .zshrc
puts colorize("Removing aliases from .zshrc...", BLUE)
if File.exist?(ZSHRC_FILE)
  content = File.read(ZSHRC_FILE)
  marker = '# 6/7 Coding Challenge aliases'
  
  if content.include?(marker)
    lines = content.split("\n")
    new_lines = []
    skip_line = false
    
    lines.each do |line|
      if line.include?(marker)
        skip_line = true
      elsif skip_line && line.start_with?('alias cc')
        # Skip aliases
      else
        skip_line = false
        new_lines << line
      end
    end
    
    # Write back the modified file
    File.write(ZSHRC_FILE, new_lines.join("\n"))
    puts colorize("Aliases removed from .zshrc", GREEN)
  else
    puts colorize("No aliases found in .zshrc.", BLUE)
  end
else
  puts colorize(".zshrc file not found.", BLUE)
end

# Remove config file
if File.exist?(CONFIG_FILE)
  File.delete(CONFIG_FILE)
  puts colorize("Configuration file removed.", GREEN)
else
  puts colorize("Configuration file not found.", BLUE)
end

# Ask about day counter
unless options[:force]
  current_day = File.exist?(DAY_COUNTER) ? File.read(DAY_COUNTER).strip : "unknown"
  print "Remove day counter? This will reset your progress (currently on day #{current_day}). (y/n): "
  remove_counter = STDIN.gets.strip.downcase == 'y'
else
  remove_counter = true
end

if remove_counter
  if File.exist?(DAY_COUNTER)
    File.delete(DAY_COUNTER)
    puts colorize("Day counter removed. Your progress has been reset.", GREEN)
  else
    puts colorize("Day counter not found.", BLUE)
  end
else
  puts colorize("Day counter preserved.", BLUE)
end

# Ask about project directory
unless options[:force]
  print "Remove project directory? This will delete all your code and logs. (y/n): "
  remove_dir = STDIN.gets.strip.downcase == 'y'
else
  remove_dir = false # Never force remove the project directory
end

if remove_dir
  if Dir.exist?(BASE_DIR)
    FileUtils.rm_rf(BASE_DIR)
    puts colorize("Project directory removed.", GREEN)
  else
    puts colorize("Project directory not found.", BLUE)
  end
else
  puts colorize("Project directory preserved.", BLUE)
end

puts
puts colorize("Uninstallation complete!", GREEN)
puts colorize("To complete the process, please run: source ~/.zshrc", BLUE)