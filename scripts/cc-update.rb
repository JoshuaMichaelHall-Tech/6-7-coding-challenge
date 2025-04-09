#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Update Script
# Updates all challenge scripts to the latest version

require_relative 'lib/cc_config'

# Load configuration
CONFIG = CCConfig.load

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
  verbose: false,
  source: nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: ccupdate [options]"
  
  opts.on("-f", "--force", "Force update without prompts") do
    options[:force] = true
  end
  
  opts.on("-v", "--verbose", "Show verbose output") do
    options[:verbose] = true
  end
  
  opts.on("--source=PATH", "Specify source repository path") do |path|
    options[:source] = path
  end
end.parse!

# Detect source repository
def find_repo_path
  # Check common locations for the repository
  potential_paths = [
    File.join(ENV['HOME'], 'projects', '6-7-coding-challenge'),
    File.join(ENV['HOME'], '6-7-coding-challenge'),
    File.join(ENV['HOME'], 'Documents', '6-7-coding-challenge'),
    File.join(ENV['HOME'], 'GitHub', '6-7-coding-challenge')
  ]
  
  potential_paths.each do |path|
    if Dir.exist?(path) && 
       Dir.exist?(File.join(path, '.git')) && 
       Dir.exist?(File.join(path, 'scripts'))
      return path
    end
  end
  
  nil
end

# Find installer script in repository
def find_installer_in_repo(repo_path)
  potential_installers = [
    File.join(repo_path, 'scripts', 'cc-installer.rb'),
    File.join(repo_path, 'bin', 'cc-installer.rb'),
    File.join(repo_path, 'cc-installer.rb')
  ]
  
  potential_installers.each do |installer|
    return installer if File.exist?(installer)
  end
  
  nil
end

# Main update process
def update(options)
  puts colorize("6/7 Coding Challenge Update", BOLD)
  puts "=" * 30
  
  # Find repository and installer
  repo_path = options[:source]
  repo_path ||= find_repo_path
  
  unless repo_path
    puts colorize("Error: Could not find repository path.", RED)
    puts "Please specify the repository path with --source option:"
    puts "ccupdate --source=/path/to/6-7-coding-challenge"
    exit 1
  end
  
  installer_path = find_installer_in_repo(repo_path)
  
  unless installer_path
    puts colorize("Error: Could not find installer script in repository.", RED)
    puts "Please check that the repository at #{repo_path} is valid."
    exit 1
  end
  
  puts colorize("Found repository at: #{repo_path}", BLUE)
  puts colorize("Using installer at: #{installer_path}", BLUE)
  
  # Check if git repository is up to date
  if Dir.exist?(File.join(repo_path, '.git'))
    puts colorize("Checking for repository updates...", BLUE)
    Dir.chdir(repo_path) do
      # Fetch remote updates
      system("git fetch --quiet")
      
      # Check if local is behind remote
      behind = `git rev-list HEAD..origin/main --count 2>/dev/null`.strip.to_i > 0
      
      if behind
        puts colorize("Repository is behind remote. Pulling latest changes...", YELLOW)
        if system("git pull --quiet")
          puts colorize("Repository updated successfully.", GREEN)
        else
          puts colorize("Failed to update repository. Continuing with current version.", YELLOW)
        end
      else
        puts colorize("Repository is up to date.", GREEN)
      end
    end
  end
  
  # Confirm update
  unless options[:force]
    print "Do you want to update all scripts to the latest version? (y/n): "
    response = gets.strip.downcase
    unless response == 'y' || response == 'yes'
      puts colorize("Update canceled.", BLUE)
      exit 0
    end
  end
  
  # Run installer with update flag
  cmd = "ruby #{installer_path} --update"
  cmd += " --force" if options[:force]
  cmd += " --verbose" if options[:verbose]
  
  puts colorize("Running update: #{cmd}", BLUE)
  exec cmd
end

# Run update
update(options)