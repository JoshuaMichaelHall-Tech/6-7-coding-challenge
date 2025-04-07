#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Push Updates Script
# Commits changes, pushes to remote, and increments the day counter

require 'fileutils'
require 'date'

# Constants
HOME_DIR = ENV['HOME']
BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')

# Check if base directory exists
unless Dir.exist?(BASE_DIR)
  puts "Error: Base project directory not found at #{BASE_DIR}"
  puts "Please run the setup script first."
  exit 1
end

# Check if day counter exists
unless File.exist?(DAY_COUNTER)
  puts "Error: Day counter file not found. Creating with default value of 1."
  File.write(DAY_COUNTER, "1")
end

# Get current day and phase information
CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i
PHASE = ((CURRENT_DAY - 1) / 100) + 1
WEEK_IN_PHASE = (((CURRENT_DAY - 1) % 100) / 6) + 1
WEEK_FORMATTED = format('%02d', WEEK_IN_PHASE)

# Set phase directory
PHASE_DIRS = {
  1 => "phase1_ruby",
  2 => "phase2_python",
  3 => "phase3_javascript",
  4 => "phase4_fullstack",
  5 => "phase5_ml_finance"
}

PHASE_DIR = PHASE_DIRS[PHASE]

# Verify current day's README exists
PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week#{WEEK_FORMATTED}", "day#{CURRENT_DAY}")
README_PATH = File.join(PROJECT_DIR, 'README.md')

unless File.exist?(README_PATH)
  puts "Error: README.md not found for day #{CURRENT_DAY}"
  puts "Expected path: #{README_PATH}"
  puts "Please make sure you've initialized this day with ccstart."
  exit 1
end

# Check if git repo is initialized
unless Dir.exist?(File.join(BASE_DIR, '.git'))
  puts "Initializing git repository..."
  Dir.chdir(BASE_DIR) do
    system("git init")
    
    # Create a basic .gitignore if it doesn't exist
    gitignore_path = File.join(BASE_DIR, '.gitignore')
    unless File.exist?(gitignore_path)
      puts "Creating .gitignore file..."
      system("curl -o .gitignore https://www.toptal.com/developers/gitignore/api/ruby,python,javascript,macos,linux,windows,visualstudiocode,vim")
    end
    
    # Check for remote
    remote_exists = system("git remote -v | grep origin > /dev/null 2>&1")
    unless remote_exists
      puts "No git remote found. You may want to add one with:"
      puts "cd #{BASE_DIR} && git remote add origin <your-repository-url>"
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
  puts "Adding changes to git..."
  system("git add .")
  
  puts "Committing changes..."
  if system("git commit -m \"#{commit_message}\"")
    puts "Changes committed successfully."
    
    # Check if remote exists before pushing
    remote_exists = system("git remote -v | grep origin > /dev/null 2>&1")
    if remote_exists
      puts "Pushing to remote..."
      if system("git push origin HEAD")
        puts "Changes pushed successfully."
      else
        puts "Warning: Failed to push changes to remote."
        puts "You may need to set up your remote or resolve conflicts."
      end
    else
      puts "No remote repository configured. Skipping push."
    end
  else
    puts "No changes to commit or commit failed."
  end
end

# Increment day counter
next_day = CURRENT_DAY + 1
File.write(DAY_COUNTER, next_day.to_s)
puts "Day counter incremented to #{next_day}"

# Prepare for next day if it's the start of a new week
next_phase = ((next_day - 1) / 100) + 1
next_week_in_phase = (((next_day - 1) % 100) / 6) + 1
next_week_formatted = format('%02d', next_week_in_phase)

if next_week_in_phase > WEEK_IN_PHASE || next_phase > PHASE
  puts "Next day starts a new week or phase."
  
  # Create directories for the next day
  next_phase_dir = PHASE_DIRS[next_phase]
  next_project_dir = File.join(BASE_DIR, next_phase_dir, "week#{next_week_formatted}")
  
  FileUtils.mkdir_p(next_project_dir)
  puts "Created directory for next week: #{next_project_dir}"
  
  # Create log directory for next phase if needed
  if next_phase > PHASE
    next_log_dir = File.join(BASE_DIR, 'logs', "phase#{next_phase}")
    FileUtils.mkdir_p(next_log_dir)
    puts "Created log directory for next phase: #{next_log_dir}"
  end
end

puts "Successfully completed Day #{CURRENT_DAY}!"
puts "Run 'ccstart' tomorrow to begin Day #{next_day}."
