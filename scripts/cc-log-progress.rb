#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Log Progress Script
# Records daily progress in weekly log files
# Supports retroactive logging for previous days

require 'fileutils'

# Constants
HOME_DIR = ENV['HOME']
BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')

# Helper method to extract section from README
def extract_section(content, section_start, section_end)
  pattern_start = "## #{section_start}"
  pattern_end = section_end ? "## #{section_end}" : nil
  
  start_index = content.index(pattern_start)
  return "" unless start_index
  
  if pattern_end
    end_index = content.index(pattern_end, start_index)
    return "" unless end_index
    
    section = content[start_index...end_index]
  else
    section = content[start_index..-1]
  end
  
  # Remove the header itself
  section = section.sub(pattern_start, "").strip
  
  # Return the section
  section
end

# Process command line arguments
if ARGV[0] && ARGV[0] =~ /^\d+$/
  LOG_DAY = ARGV[0].to_i
  puts "Logging for specified day: #{LOG_DAY}"
else
  # If no day specified, use current day counter
  unless File.exist?(DAY_COUNTER)
    puts "Error: Day counter file not found. Run setup script first."
    exit 1
  end
  
  LOG_DAY = File.read(DAY_COUNTER).strip.to_i
  puts "Logging for current day: #{LOG_DAY}"
end

# Validate the day number
if LOG_DAY < 1
  puts "Error: Invalid day number. Days start from 1."
  exit 1
end

CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i
if LOG_DAY > CURRENT_DAY
  puts "Error: Cannot log for future days. Current day is #{CURRENT_DAY}."
  exit 1
end

# Calculate phase, week based on the day to log
PHASE = ((LOG_DAY - 1) / 100) + 1
WEEK_IN_PHASE = (((LOG_DAY - 1) % 100) / 6) + 1

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

# Set paths
PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week#{WEEK_FORMATTED}", "day#{LOG_DAY}")
LOG_FILE = File.join(BASE_DIR, 'logs', "phase#{PHASE}", "week#{WEEK_FORMATTED}.md")

# Check if project directory exists
unless Dir.exist?(PROJECT_DIR)
  puts "Error: Project directory not found at #{PROJECT_DIR}"
  puts "Please make sure you've initialized this day with ccstart."
  exit 1
end

# Check if README exists
README_PATH = File.join(PROJECT_DIR, 'README.md')
unless File.exist?(README_PATH)
  puts "Error: README.md not found in #{PROJECT_DIR}"
  puts "Please make sure you've initialized this day with ccstart."
  exit 1
end

# Read README content
readme_content = File.read(README_PATH)

# Create log directory if needed
log_dir = File.dirname(LOG_FILE)
FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)

# Check if log file exists, create if not
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

# Check if day entry already exists
log_content = File.read(LOG_FILE)
day_entry_pattern = /^## Day #{LOG_DAY}$/

if log_content.match(day_entry_pattern)
  puts "Warning: An entry for Day #{LOG_DAY} already exists in the log file."
  print "Do you want to replace it? (y/n): "
  replace_entry = STDIN.gets.chomp.downcase
  
  if replace_entry != 'y'
    puts "Operation canceled."
    exit 0
  end
  
  # Remove existing entry
  lines = log_content.split("\n")
  start_index = lines.find_index { |line| line.match(day_entry_pattern) }
  
  if start_index
    # Find the end of this entry (next day entry or end of file)
    end_index = lines[start_index+1..-1].find_index { |line| line.match(/^## Day \d+$/) }
    
    if end_index
      end_index += start_index + 1 # Adjust for the slice from start_index+1
    else
      end_index = lines.length
    end
    
    # Remove the entry
    lines.slice!(start_index...end_index)
    
    # Write updated content back
    File.write(LOG_FILE, lines.join("\n"))
    puts "Removed existing entry for Day #{LOG_DAY}"
  end
end

# Find the right spot to insert the new entry (entries should be in chronological order)
lines = File.readlines(LOG_FILE, chomp: true)
day_entries = lines.each_with_index.select { |line, _| line.match(/^## Day \d+$/) }

insert_index = nil
inserted = false

day_entries.each do |entry, index|
  entry_day = entry.match(/^## Day (\d+)$/)[1].to_i
  if LOG_DAY < entry_day
    insert_index = index
    inserted = true
    break
  end
end

if inserted
  # Insert at the appropriate spot
  day_entry = "## Day #{LOG_DAY}"
  lines.insert(insert_index, day_entry)
else
  # Append to the end
  day_entry = "## Day #{LOG_DAY}"
  # Find the last daily log entry or the Daily Logs header
  last_entry_index = day_entries.empty? ? 
    lines.find_index { |line| line.match(/^## Daily Logs$/) } : 
    day_entries.last[1]
    
  if last_entry_index
    # Find the next section after the last entry
    next_section_index = lines[last_entry_index+1..-1].find_index { |line| line.match(/^## /) }
    
    if next_section_index
      insert_index = last_entry_index + 1 + next_section_index
      lines.insert(insert_index, "", day_entry)
    else
      lines << "" << day_entry
    end
  else
    lines << "" << day_entry
  end
end

# Extract sections from README
focus_section = extract_section(readme_content, "Today's Focus", "Launch School Connection")
ls_section = extract_section(readme_content, "Launch School Connection", "Progress Log")
progress_section = extract_section(readme_content, "Progress Log", "Reflections")
reflections_section = extract_section(readme_content, "Reflections", nil)

# Find the index right after the day entry
day_index = lines.find_index { |line| line == day_entry }

if day_index
  # Insert content after the day entry
  current_index = day_index + 1
  
  # Add focus section
  focus_lines = focus_section.split("\n")
  lines.insert(current_index, *focus_lines)
  current_index += focus_lines.length
  
  # Add LS section
  ls_lines = ls_section.split("\n")
  lines.insert(current_index, *ls_lines)
  current_index += ls_lines.length
  
  # Add progress section
  progress_lines = progress_section.split("\n")
  lines.insert(current_index, *progress_lines)
  current_index += progress_lines.length
  
  # Add reflections section
  lines.insert(current_index, "### Reflections")
  reflections_lines = reflections_section.split("\n")
  lines.insert(current_index + 1, *reflections_lines)
  current_index += reflections_lines.length + 1
  
  # Add blank line
  lines.insert(current_index, "")
end

# Write updated content
File.write(LOG_FILE, lines.join("\n"))

puts "Progress for Day #{LOG_DAY} successfully logged to #{LOG_FILE}"
