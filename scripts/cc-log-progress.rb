#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Log Progress Script
# Records daily progress in weekly log files
# Supports retroactive logging for previous days

require 'fileutils'
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

# Helper method to extract section from README
def extract_section(content, section_name, next_section_name = nil)
  # Define the patterns to search for
  pattern_start = "## #{section_name}"
  pattern_end = next_section_name ? "## #{next_section_name}" : nil
  
  # Find the start of the section
  start_index = content.index(pattern_start)
  return "" unless start_index
  
  # Find the end of the section
  if pattern_end
    # Look for the next section
    end_index = content.index(pattern_end, start_index)
    return content[start_index..-1].strip unless end_index
    
    # Extract the section content
    section = content[start_index...end_index]
  else
    # If no next section, take everything until the end
    section = content[start_index..-1]
  end
  
  # Remove the section header itself
  section_content = section.sub(pattern_start, "").strip
  
  # Remove HTML comments
  section_content = section_content.gsub(/<!--.*?-->/m, "")
  
  # Ensure content has proper formatting (remove extra blank lines)
  section_content = section_content.gsub(/\n{3,}/, "\n\n").strip
  
  section_content
end

# Function to get all section names from README
def get_section_names(content)
  # Find all section headers (## Section Name)
  content.scan(/^## (.*?)$/m).flatten
end

# Function to determine phase and week for a specific day
def get_phase_and_week_for_day(day)
  phases = CONFIG["challenge"]["phases"]
  days_per_week = CONFIG["challenge"]["days_per_week"].to_i
  
  # Calculate phase based on cumulative days
  cumulative_days = 0
  phase_num = 1
  
  phases.each do |num, phase|
    days_in_phase = phase["days"].to_i
    if day <= cumulative_days + days_in_phase
      phase_num = num.to_i
      break
    end
    cumulative_days += days_in_phase
  end
  
  # Calculate week in phase
  day_in_phase = day - cumulative_days
  week_in_phase = ((day_in_phase - 1) / days_per_week) + 1
  
  {
    phase: phase_num,
    week_in_phase: week_in_phase,
    week_formatted: format('%02d', week_in_phase),
    phase_dir: phases[phase_num.to_s]["dir"],
    phase_name: phases[phase_num.to_s]["name"]
  }
end

# Process command line arguments
if ARGV[0] && ARGV[0] =~ /^\d+$/
  LOG_DAY = ARGV[0].to_i
  puts colorize("Logging for specified day: #{LOG_DAY}", BLUE)
else
  # If no day specified, use current day counter
  LOG_DAY = CCConfig.current_day
  puts colorize("Logging for current day: #{LOG_DAY}", BLUE)
end

# Validate the day number
if LOG_DAY < 1
  puts colorize("Error: Invalid day number. Days start from 1.", RED)
  exit 1
end

CURRENT_DAY = CCConfig.current_day
if LOG_DAY > CURRENT_DAY
  puts colorize("Error: Cannot log for future days. Current day is #{CURRENT_DAY}.", RED)
  exit 1
end

# Get phase and week info for the specified day
day_info = get_phase_and_week_for_day(LOG_DAY)
PHASE = day_info[:phase]
WEEK_IN_PHASE = day_info[:week_in_phase]
WEEK_FORMATTED = day_info[:week_formatted]
PHASE_DIR = day_info[:phase_dir]
PHASE_NAME = day_info[:phase_name]

# Set paths
BASE_DIR = CCConfig.base_dir
LOG_BASE_DIR = CCConfig.log_dir # This may be different if using a separate log repo
PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week#{WEEK_FORMATTED}", "day#{LOG_DAY}")
LOG_FILE = File.join(LOG_BASE_DIR, 'logs', "phase#{PHASE}", "week#{WEEK_FORMATTED}.md")

# Check if project directory exists
unless Dir.exist?(PROJECT_DIR)
  puts colorize("Error: Project directory not found at #{PROJECT_DIR}", RED)
  puts "Please make sure you've initialized this day with ccstart."
  exit 1
end

# Check if README exists
README_PATH = File.join(PROJECT_DIR, 'README.md')
unless File.exist?(README_PATH)
  puts colorize("Error: README.md not found in #{PROJECT_DIR}", RED)
  puts "Please make sure you've initialized this day with ccstart."
  exit 1
end

# Read README content
readme_content = File.read(README_PATH)

# Create log directory if needed
log_dir = File.dirname(LOG_FILE)
FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)

# Calculate days per week for this phase
DAYS_PER_WEEK = CONFIG["challenge"]["days_per_week"].to_i

# Calculate the start and end days for the week
cumulative_days = 0
CONFIG["challenge"]["phases"].each do |num, phase|
  if num.to_i < PHASE
    cumulative_days += phase["days"].to_i
  end
end

week_start = cumulative_days + ((WEEK_IN_PHASE - 1) * DAYS_PER_WEEK) + 1
week_end = [week_start + DAYS_PER_WEEK - 1, cumulative_days + CONFIG["challenge"]["phases"][PHASE.to_s]["days"].to_i].min

# Check if log file exists, create if not
unless File.exist?(LOG_FILE)
  puts colorize("Creating new log file: #{LOG_FILE}", GREEN)
  
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

# Check if day entry already exists
log_content = File.read(LOG_FILE)
day_entry_pattern = /^### Day #{LOG_DAY}$/

if log_content.match(day_entry_pattern)
  puts colorize("Warning: An entry for Day #{LOG_DAY} already exists in the log file.", YELLOW)
  print "Do you want to replace it? (y/n): "
  replace_entry = $stdin.gets.chomp.downcase
  
  if replace_entry != 'y'
    puts colorize("Operation canceled.", BLUE)
    exit 0
  end
  
  # Remove existing entry
  lines = log_content.split("\n")
  start_index = lines.find_index { |line| line.match(day_entry_pattern) }
  
  if start_index
    # Find the end of this entry (next day entry or next section)
    end_index = nil
    (start_index+1...lines.length).each do |i|
      if lines[i].match(/^### Day \d+$/) || lines[i].match(/^## /)
        end_index = i
        break
      end
    end
    
    end_index ||= lines.length
    
    # Remove the entry
    lines.slice!(start_index...end_index)
    
    # Write updated content back
    File.write(LOG_FILE, lines.join("\n"))
    puts colorize("Removed existing entry for Day #{LOG_DAY}", GREEN)
  end
end

# Find the right spot to insert the new entry (entries should be in chronological order)
lines = File.readlines(LOG_FILE, chomp: true)
day_entries = lines.each_with_index.select { |line, _| line.match(/^### Day \d+$/) }

insert_index = nil
inserted = false

day_entries.each do |entry, index|
  entry_day = entry.match(/^### Day (\d+)$/)[1].to_i
  if LOG_DAY < entry_day
    insert_index = index
    inserted = true
    break
  end
end

if inserted
  # Insert at the appropriate spot
  day_entry = "### Day #{LOG_DAY}"
  lines.insert(insert_index, day_entry)
else
  # Append to the end of daily logs
  day_entry = "### Day #{LOG_DAY}"
  
  # Find the last daily log entry or the Daily Logs header
  daily_logs_index = lines.find_index { |line| line.match(/^## Daily Logs$/) }
  
  if daily_logs_index
    # Find the next section after Daily Logs
    next_section_index = nil
    ((daily_logs_index + 1)...lines.length).each do |i|
      if lines[i].match(/^## /) && !lines[i].match(/^## Daily Logs$/)
        next_section_index = i
        break
      end
    end
    
    if next_section_index
      # Insert before next section
      lines.insert(next_section_index, "", day_entry)
    else
      # No next section, append to end
      lines << "" << day_entry
    end
  else
    # No Daily Logs section found, create one
    lines << "" << "## Daily Logs" << "" << day_entry
  end
end

# Get all sections in README
section_names = get_section_names(readme_content)

# Get the pairs of section names for extraction
section_pairs = []
section_names.each_with_index do |name, index|
  if index < section_names.length - 1
    section_pairs << [name, section_names[index + 1]]
  else
    section_pairs << [name, nil]
  end
end

# Extract all sections from README and add to log
day_index = lines.find_index { |line| line == day_entry }

if day_index
  current_index = day_index + 1
  
  # Process each section
  section_pairs.each do |current_section, next_section|
    # Skip the title (first section), as it's already captured in the day entry
    next if current_section.match(/Day \d+ .*/)
    
    # Extract section content
    section_content = extract_section(readme_content, current_section, next_section)
    
    # Skip empty sections
    next if section_content.strip.empty?
    
    # Add section header
    lines.insert(current_index, "#### #{current_section}:")
    current_index += 1
    
    # Add section content with proper indentation
    section_lines = section_content.split("\n")
    lines.insert(current_index, *section_lines)
    current_index += section_lines.length
    
    # Add blank line after section
    lines.insert(current_index, "")
    current_index += 1
  end
  
  # Remove consecutive blank lines and trailing blank line if any
  cleaned_lines = []
  previous_blank = false
  
  lines.each do |line|
    is_blank = line.strip.empty?
    
    if is_blank && previous_blank
      # Skip consecutive blank lines
    else
      cleaned_lines << line
    end
    
    previous_blank = is_blank
  end
  
  # Remove trailing blank line if exists
  cleaned_lines.pop if cleaned_lines.last&.strip&.empty?
  
  # Write updated content
  File.write(LOG_FILE, cleaned_lines.join("\n"))
  
  puts colorize("Progress for Day #{LOG_DAY} successfully logged to #{LOG_FILE}", GREEN)
else
  puts colorize("Error: Failed to find insertion point in log file.", RED)
end
