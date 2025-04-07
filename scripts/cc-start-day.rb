#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Start Day Script
# Initializes the environment for a new challenge day

require 'fileutils'
require 'date'

# Constants
HOME_DIR = ENV['HOME']
BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')

# Get current day
unless File.exist?(DAY_COUNTER)
  puts "Error: Day counter file not found. Creating with default value of 1."
  File.write(DAY_COUNTER, "1")
end

CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i
PHASE = ((CURRENT_DAY - 1) / 100) + 1
WEEK_IN_PHASE = (((CURRENT_DAY - 1) % 100) / 6) + 1
DAY_OF_WEEK = Date.today.cwday # 1-7, where 1 is Monday and 7 is Sunday

# Check if it's Sunday
if DAY_OF_WEEK == 7
  puts "Today is the Sabbath. Time for rest, not coding."
  exit 0
end

# Format week with leading zero
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

# Check if base directory exists
unless Dir.exist?(BASE_DIR)
  puts "Error: Base project directory not found at #{BASE_DIR}"
  puts "Please run the setup script first."
  exit 1
end

# Create directories if needed
PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week#{WEEK_FORMATTED}", "day#{CURRENT_DAY}")
FileUtils.mkdir_p(PROJECT_DIR)

LOG_DIR = File.join(BASE_DIR, 'logs', "phase#{PHASE}")
FileUtils.mkdir_p(LOG_DIR)

# Initialize log file if needed
LOG_FILE = File.join(LOG_DIR, "week#{WEEK_FORMATTED}.md")

unless File.exist?(LOG_FILE)
  puts "Creating new log file: #{LOG_FILE}"
  week_start = ((WEEK_IN_PHASE - 1) * 6) + 1
  week_end = WEEK_IN_PHASE * 6
  
  File.open(LOG_FILE, 'w') do |f|
    f.puts "# Week #{WEEK_FORMATTED} (Days #{week_start}-#{week_end})"
    f.puts ""
    f.puts "## Week Overview"
    f.puts "- **Focus**: "
    f.puts "- **Launch School Connection**: "
    f.puts "- **Weekly Goals**:"
    f.puts "  - "
    f.puts "  - "
    f.puts "  - "
    f.puts ""
    f.puts "## Daily Logs"
    f.puts ""
  end
end

# Set up the day's work if README doesn't exist
README_PATH = File.join(PROJECT_DIR, 'README.md')

unless File.exist?(README_PATH)
  puts "Setting up Day #{CURRENT_DAY} (Phase #{PHASE}, Week #{WEEK_FORMATTED})"
  
  File.open(README_PATH, 'w') do |f|
    f.puts "# Day #{CURRENT_DAY} - Phase #{PHASE} (Week #{WEEK_FORMATTED})"
    f.puts ""
    f.puts "## Today's Focus"
    f.puts "- [ ] Primary goal: "
    f.puts "- [ ] Secondary goal: "
    f.puts "- [ ] Stretch goal: "
    f.puts ""
    f.puts "## Launch School Connection"
    f.puts "- Current course: "
    f.puts "- Concept application: "
    f.puts ""
    f.puts "## Progress Log"
    f.puts "- Started: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    f.puts "- "
    f.puts ""
    f.puts "## Reflections"
    f.puts "- "
    f.puts ""
  end
else
  puts "Using existing README for Day #{CURRENT_DAY}"
end

# Determine editor
if system("which nvim > /dev/null 2>&1")
  EDITOR = "nvim"
elsif system("which vim > /dev/null 2>&1")
  EDITOR = "vim"
else
  EDITOR = ENV['EDITOR'] || "vi"
end

# Check if tmux is installed
if system("which tmux > /dev/null 2>&1")
  # Kill existing session if it exists
  system("tmux has-session -t coding-challenge 2>/dev/null && tmux kill-session -t coding-challenge")
  
  # Change to project directory
  Dir.chdir(PROJECT_DIR)
  
  # Start tmux session
  puts "Starting tmux session..."
  exec "tmux new-session -s coding-challenge '#{EDITOR} README.md'"
else
  puts "Warning: tmux is not installed. Opening project directory without tmux."
  Dir.chdir(PROJECT_DIR)
  exec "#{EDITOR} README.md"
end
