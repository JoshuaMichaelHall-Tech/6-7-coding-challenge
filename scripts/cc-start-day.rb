#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Start Day Script
# Initializes the environment for a new challenge day

require 'fileutils'
require 'date'
require_relative 'lib/cc_config'

# Load configuration
CONFIG = CCConfig.load

# Get current day
CURRENT_DAY = CCConfig.current_day
PHASE = CCConfig.current_phase
WEEK_IN_PHASE = CCConfig.week_in_phase
WEEK_FORMATTED = CCConfig.week_formatted
DAY_OF_WEEK = Date.today.cwday # 1-7, where 1 is Monday and 7 is Sunday

# Get phase name
PHASE_NAME = CCConfig.phase_name(PHASE)

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

# Check if it's a rest day (typically Sunday)
if DAY_OF_WEEK == 7
  puts colorize("Today is the Sabbath. Time for rest, not coding.", YELLOW)
  exit 0
end

# Set directories
PHASE_DIR = CCConfig.phase_dir
BASE_DIR = CCConfig.base_dir
LOG_DIR = CCConfig.log_dir

# Check if base directory exists
unless Dir.exist?(BASE_DIR)
  puts colorize("Error: Base project directory not found at #{BASE_DIR}", RED)
  puts "Please run the setup script first."
  exit 1
end

# Create directories if needed
PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week#{WEEK_FORMATTED}", "day#{CURRENT_DAY}")
FileUtils.mkdir_p(PROJECT_DIR)

# Create log directory path
phase_log_dir = File.join(LOG_DIR, 'logs', "phase#{PHASE}")
FileUtils.mkdir_p(phase_log_dir)

# Initialize log file if needed
LOG_FILE = File.join(phase_log_dir, "week#{WEEK_FORMATTED}.md")

unless File.exist?(LOG_FILE)
  puts colorize("Creating new log file: #{LOG_FILE}", GREEN)
  days_per_week = CONFIG["challenge"]["days_per_week"].to_i
  
  # Calculate start and end days for this week within the phase
  cumulative_days = 0
  CONFIG["challenge"]["phases"].each do |num, phase|
    if num.to_i < PHASE
      cumulative_days += phase["days"].to_i
    end
  end
  
  week_start = cumulative_days + ((WEEK_IN_PHASE - 1) * days_per_week) + 1
  week_end = week_start + days_per_week - 1
  
  File.open(LOG_FILE, 'w') do |f|
    f.puts "# Week #{WEEK_FORMATTED} (Days #{week_start}-#{week_end})"
    f.puts ""
    f.puts "## Week Overview"
    f.puts "- **Focus**: "
    f.puts "- **Challenge Connection**: "
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
  puts colorize("Setting up Day #{CURRENT_DAY} (Phase #{PHASE}, Week #{WEEK_FORMATTED})", GREEN)
  
  File.open(README_PATH, 'w') do |f|
    f.puts "# Day #{CURRENT_DAY} - Phase #{PHASE}: #{PHASE_NAME} (Week #{WEEK_FORMATTED})"
    f.puts ""
    f.puts "## Today's Focus"
    f.puts "- [ ] Primary goal: "
    f.puts "- [ ] Secondary goal: "
    f.puts "- [ ] Stretch goal: "
    f.puts ""
    f.puts "## Challenge Connection"
    f.puts "- Current project: "
    f.puts "- Concept application: "
    f.puts ""
    f.puts "## Project Context"
    f.puts "<!-- Describe the larger project this day's work contributes to -->"
    f.puts ""
    f.puts "## Tools & Technologies"
    f.puts "<!-- List the specific technologies, frameworks, and tools used today -->"
    f.puts "- "
    f.puts "- "
    f.puts "- "
    f.puts ""
    f.puts "## Progress Log"
    f.puts "- Started: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    f.puts "- "
    f.puts ""
    f.puts "## Code Highlight"
    f.puts "```"
    f.puts "# Include a significant code snippet from today's work"
    f.puts "# with comments explaining key aspects"
    f.puts "```"
    f.puts ""
    f.puts "## Challenges Faced"
    f.puts "<!-- Describe technical challenges and how you addressed them -->"
    f.puts "- "
    f.puts "- "
    f.puts ""
    f.puts "## Learning Resources Used"
    f.puts "<!-- List books, documentation, tutorials, etc. that you referenced -->"
    f.puts "- "
    f.puts "- "
    f.puts ""
    f.puts "## Reflections"
    f.puts "<!-- Share insights and lessons learned today -->"
    f.puts "- "
    f.puts "- "
    f.puts ""
    f.puts "## Tomorrow's Plan"
    f.puts "<!-- Outline what you plan to work on next -->"
    f.puts "- "
    f.puts "- "
    f.puts ""
  end
else
  puts colorize("Using existing README for Day #{CURRENT_DAY}", BLUE)
end

# Get preferred editor from config
EDITOR = CCConfig.editor

# Use tmux if configured and available
if CCConfig.use_tmux? && system("which tmux > /dev/null 2>&1")
  # Kill existing session if it exists
  system("tmux has-session -t coding-challenge 2>/dev/null && tmux kill-session -t coding-challenge")
  
  # Change to project directory
  Dir.chdir(PROJECT_DIR)
  
  # Start tmux session
  puts colorize("Starting tmux session with #{EDITOR}...", GREEN)
  exec "tmux new-session -s coding-challenge '#{EDITOR} README.md'"
else
  # Just open the editor directly if tmux is not available or not preferred
  puts colorize("Opening project directory with #{EDITOR}...", GREEN)
  Dir.chdir(PROJECT_DIR)
  exec "#{EDITOR} README.md"
end
