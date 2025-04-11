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
LOG_DIR = CCConfig.log_dir
PHASE_DIR = CCConfig.phase_dir
PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week#{WEEK_FORMATTED}", "day#{CURRENT_DAY}")
README_PATH = File.join(PROJECT_DIR, 'README.md')

# Function to determine phase and week for a specific day
def get_phase_and_week_for_day(day)
  CCConfig.get_phase_and_week_for_day(day)
end

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

# Check if using GitHub
USING_GITHUB = CCConfig.use_github?

# Prompt for commit message
print "Enter commit message (or press Enter for default): "
commit_message = $stdin.gets.chomp

if commit_message.empty?
  commit_message = "Complete Day #{CURRENT_DAY} - Phase #{PHASE} Week #{WEEK_FORMATTED}"
end

# Git operations for main repository
if USING_GITHUB
  Dir.chdir(BASE_DIR) do
    puts colorize("Adding changes to git in #{BASE_DIR}...", BLUE)
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
          puts colorize("No remote repository configured for main repo. Skipping push.", BLUE)
          github_username = CONFIG['user']['github_username']
          if github_username && !github_username.empty?
            repo_name = File.basename(BASE_DIR)
            puts "To add a remote for the main repository, run:"
            puts "cd #{BASE_DIR}"
            puts "git remote add origin https://github.com/#{github_username}/#{repo_name}.git"
          end
        end
      else
        puts colorize("Auto-push is disabled. Skipping push.", BLUE)
      end
    else
      puts colorize("No changes to commit or commit failed in main repository.", YELLOW)
    end
  end
  
  # Git operations for log repository if different from base directory
  if LOG_DIR != BASE_DIR
    Dir.chdir(LOG_DIR) do
      puts colorize("Adding changes to git in #{LOG_DIR}...", BLUE)
      system("git add .")
      
      puts colorize("Committing changes to log repository...", BLUE)
      if system("git commit -m \"#{commit_message} (Logs)\"")
        puts colorize("Log changes committed successfully.", GREEN)
        
        # Check if auto-push is enabled and remote exists
        if CCConfig.auto_push?
          remote_exists = system("git remote -v | grep origin > /dev/null 2>&1")
          if remote_exists
            puts colorize("Pushing logs to remote...", BLUE)
            if system("git push origin HEAD")
              puts colorize("Log changes pushed successfully.", GREEN)
            else
              puts colorize("Warning: Failed to push log changes to remote.", YELLOW)
              puts "You may need to set up your remote or resolve conflicts."
            end
          else
            puts colorize("No remote repository configured for logs. Skipping push.", BLUE)
            
            github_username = CONFIG['user']['github_username']
            if github_username && !github_username.empty?
              # Use correct repository name for logs
              if CCConfig.is_github_log_repo? && CCConfig.github_log_repo
                repo_name = CCConfig.github_log_repo
              else
                repo_name = File.basename(LOG_DIR)
              end
              
              puts "To add a remote for the logs repository, run:"
              puts "cd #{LOG_DIR}"
              puts "git remote add origin https://github.com/#{github_username}/#{repo_name}.git"
            end
          end
        else
          puts colorize("Auto-push is disabled. Skipping push for logs.", BLUE)
        end
      else
        puts colorize("No changes to commit or commit failed in log repository.", YELLOW)
      end
    end
  end
end

# Increment day counter
next_day = CURRENT_DAY + 1
CCConfig.update_day(next_day)
puts colorize("Day counter incremented to #{next_day}", GREEN)

# Prepare for next day
next_day_info = get_phase_and_week_for_day(next_day)
next_phase = next_day_info[:phase]
next_week_in_phase = next_day_info[:week_in_phase]
next_week_formatted = next_day_info[:week_formatted]
next_phase_dir = next_day_info[:phase_dir]

# Check if next day starts a new week or phase
if next_week_in_phase > WEEK_IN_PHASE || next_phase > PHASE
  puts colorize("Next day starts a new week or phase.", BLUE)
  
  # Create directories for the next day
  next_project_dir = File.join(BASE_DIR, next_phase_dir, "week#{next_week_formatted}")
  FileUtils.mkdir_p(next_project_dir)
  puts colorize("Created directory for next week: #{next_project_dir}", GREEN)
  
  # Create log directory for next phase if needed
  if next_phase > PHASE
    next_log_dir = File.join(LOG_DIR, 'logs', "phase#{next_phase}")
    FileUtils.mkdir_p(next_log_dir)
    puts colorize("Created log directory for next phase: #{next_log_dir}", GREEN)
  end
end

puts ""
puts colorize("Successfully completed Day #{CURRENT_DAY}!", GREEN)
puts colorize("Run 'ccstart' tomorrow to begin Day #{next_day}.", BLUE)
