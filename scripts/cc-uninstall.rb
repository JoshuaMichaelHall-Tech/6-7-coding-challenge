#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Uninstall Script
# Removes all challenge scripts and configuration

# Constants
HOME_DIR = ENV['HOME']
BIN_DIR = File.join(HOME_DIR, 'bin')
BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
CONFIG_FILE = File.join(HOME_DIR, '.cc-config')
DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
ZSHRC_FILE = File.join(HOME_DIR, '.zshrc')
INSTALLER_PATH = File.join(BIN_DIR, 'cc-installer.rb')

# ANSI color codes
RESET = "\e[0m"
BOLD = "\e[1m"
GREEN = "\e[32m"
YELLOW = "\e[33m"
BLUE = "\e[34m"
RED = "\e[31m"

# Check if color should be disabled
NO_COLOR = ENV['NO_COLOR'] || ARGV.include?('--no-color')

def colorize(text, color_code)
  return text if NO_COLOR
  "#{color_code}#{text}#{RESET}"
end

# Check if installer exists and use it if available
if File.exist?(INSTALLER_PATH)
  args = ARGV + ['--uninstall']
  command = "ruby #{INSTALLER_PATH} #{args.join(' ')}"
  exec command
end

# If installer is not available, proceed with manual uninstallation
puts colorize("6/7 Coding Challenge Uninstaller", BOLD)
puts "=" * 60
puts
puts colorize("WARNING: Installer script not found, proceeding with manual uninstallation.", YELLOW)
puts

# Confirm uninstallation
unless ARGV.include?('--force')
  print "Are you sure you want to uninstall the 6/7 Coding Challenge? (y/n): "
  response = STDIN.gets.strip.downcase
  unless response == 'y'
    puts "Uninstallation canceled."
    exit 0
  end
end

# Remove scripts
puts "Removing scripts..."
script_count = 0
Dir.glob(File.join(BIN_DIR, "cc-*.rb")).each do |script|
  if File.exist?(script)
    File.delete(script)
    puts "  Deleted: #{script}" if ARGV.include?('--verbose')
    script_count += 1
  end
end
puts colorize("#{script_count} scripts removed.", GREEN) if script_count > 0

# Remove aliases from .zshrc
puts "Removing aliases from .zshrc..."
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
    puts "No aliases found in .zshrc."
  end
else
  puts "  .zshrc file not found."
end

# Remove config file
if File.exist?(CONFIG_FILE)
  File.delete(CONFIG_FILE)
  puts colorize("Configuration file removed.", GREEN)
else
  puts "Configuration file not found."
end

# Ask about day counter
unless ARGV.include?('--force')
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
    puts "Day counter not found."
  end
else
  puts colorize("Day counter preserved.", BLUE)
end

# Ask about project directory
unless ARGV.include?('--force')
  print "Remove project directory? This will delete all your code and logs. (y/n): "
  remove_dir = STDIN.gets.strip.downcase == 'y'
else
  remove_dir = false # Never force removal of project directory
end

if remove_dir
  if Dir.exist?(BASE_DIR)
    require 'fileutils'
    FileUtils.rm_rf(BASE_DIR)
    puts colorize("Project directory removed.", GREEN)
  else
    puts "Project directory not found."
  end
else
  puts colorize("Project directory preserved.", BLUE)
end

puts
puts colorize("Uninstallation complete!", GREEN)
puts "To complete the process, please run: source ~/.zshrc"
