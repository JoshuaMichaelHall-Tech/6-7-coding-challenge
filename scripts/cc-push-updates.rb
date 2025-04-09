#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Push Updates Script
# Commits changes, pushes to remote, and increments the day counter

require 'fileutils'
require 'date'
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

# Get current day info
CURRENT_DAY = CCConfig.current_day
PHASE = CCConfig.current_phase
WEEK_IN_PHASE = CCConfig.week_in_phase
WEEK_FORMATTED = CCConfig.week_formatted

# Set paths
BASE_DIR = CCConfig.base_dir
PHASE_DIR = CCConfig.phase_dir
PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week#{WEEK_FORMATTED}", "day#{CURRENT_DAY}")
README_PATH = File.join(PROJECT_DIR, 'README.md')

# Check if project directory and README exist
unless Dir.exist?(PROJECT_DIR)
  puts colorize("Error: Project directory not found at #{PROJECT_DIR}", RED)
  puts "Please make sure you've initialized this day with ccstart."
  exit 1
end

unless File.exist?(README_PATH)
  puts colorize("Error: README.md not found for day #{CURRENT_DAY}", RED)
  puts "Expected path: #{README_PATH}"
  puts "Please make sure you've initialized this day with ccstart."
  exit 1
end

# Check if git repo is initialized
unless Dir.exist?(File.join(BASE_DIR, '.git'))
  puts colorize("Git repository not found. Initializing...", YELLOW)
  Dir.chdir(BASE_DIR) do
    system("git init")
    
    # Create a basic .gitignore if it doesn't exist
    gitignore_path = File.join(BASE_DIR, '.gitignore')
    unless File.exist?(gitignore_path)
      puts colorize("Creating .gitignore file...", BLUE)
      basic_gitignore = <<~GITIGNORE
        # System Files
        .DS_Store
        .DS_Store?
        ._*
        .Spotlight-V100
        .Trashes
        ehthumbs.db
        Thumbs.db
        desktop.ini
        .directory
        *~
        .*.swp
        .*.swo
        
        # Editor directories and files
        .idea/
        .vscode/
        *.swp
        *.swo
        *~
        *.sublime-workspace
        
        # Obsidian configuration directories
        .obsidian/
        **/.obsidian/
        docs/.obsidian/
        */obsidian/
      GITIGNORE
      
      File.write(gitignore_path, basic_gitignore)
    end
    
    # Check for remote
    remote_exists = system("git remote -v | grep origin > /dev/null 2>&1")
    unless remote_exists
      # Try to get GitHub username from config
      github_username = CONFIG['user']['github_username']
      if github_username && !github_username.empty?
        suggested_remote = "https://github.com/#{github_username}/6-7-coding-challenge.git"
        puts colorize("No git remote found. You may want to add one with:", BLUE)
        puts "git remote add origin #{suggested_remote}"
      else
        puts colorize("No git remote found. You may want to add one with:", BLUE)
        puts "git remote add origin <your-repository-url>"
      end
    end
  end
end

# Prompt for commit message
print "Enter commit message (or press Enter for default): "
commit_message = STDIN.gets.chomp

if commit_message.empty?
  commit_message = "Complete Day #{CURRENT_DAY} - Phase #{PHASE} Week #{WEEK_FORMATTED}"
end

# Git operations
Dir.chdir(BASE_DIR) do
  puts colorize("Adding changes to git...", BLUE)
  system("git add .")
  
  puts colorize("Committing changes...", BLUE)
  if system("git commit -m \"#{commit_message}\"")
    puts colorize("Changes committed successfully.", GREEN)
    
    # Check if auto-push is enabled and remote exists
    if CCConfig.auto_push?
      remote_exists = system("git remote -v | grep origin > /dev/null 2>&1")
      if remote_exists
        puts colorize("Pushing to remote...", BLUE)
        if system("git push origin HEAD")
          puts colorize("Changes pushed successfully.", GREEN)
        else
          puts colorize("Warning: Failed to push changes to remote.", YELLOW)
          puts "You may need to set up your remote or resolve conflicts."
        end
      else
        puts colorize("No remote repository configured. Skipping push.", BLUE)
      end
    else
      puts colorize("Auto-push is disabled. Skipping push.", BLUE)
    end
  else
    puts colorize("No changes to commit or commit failed.", YELLOW)
  end
end

# Increment day counter
next_day = CURRENT_DAY + 1
CCConfig.update_day(next_day)
puts colorize("Day counter incremented to #{next_day}", GREEN)

# Prepare for next day if it's the start of a new week or phase
next_phase = ((next_day - 1) / CONFIG["challenge"]["days_per_phase"].to_i) + 1
next_week_in_phase = (((next_day - 1) % CONFIG["challenge"]["days_per_phase"].to_i) / CONFIG["challenge"]["days_per_week"].to_i) + 1
next_week_formatted = format('%02d', next_week_in_phase)

if next_week_in_phase > WEEK_IN_PHASE || next_phase > PHASE
  puts colorize("Next day starts a new week or phase.", BLUE)
  
  # Get the directory for the next phase
  next_phase_dir = CONFIG["challenge"]["phases"][next_phase.to_s]["dir"]
  
  # Create directories for the next day
  next_project_dir = File.join(BASE_DIR, next_phase_dir, "week#{next_week_formatted}")
  
  FileUtils.mkdir_p(next_project_dir)
  puts colorize("Created directory for next week: #{next_project_dir}", GREEN)
  
  # Create log directory for next phase if needed
  if next_phase > PHASE
    next_log_dir = File.join(BASE_DIR, 'logs', "phase#{next_phase}")
    FileUtils.mkdir_p(next_log_dir)
    puts colorize("Created log directory for next phase: #{next_log_dir}", GREEN)
  end
end

puts ""
puts colorize("Successfully completed Day #{CURRENT_DAY}!", GREEN)
puts colorize("Run 'ccstart' tomorrow to begin Day #{next_day}.", BLUE)