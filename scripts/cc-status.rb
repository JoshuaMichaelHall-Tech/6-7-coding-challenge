#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Status Script
# Displays current challenge status and progress

require 'date'

# Constants
HOME_DIR = ENV['HOME']
BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
CONFIG_FILE = File.join(HOME_DIR, '.cc-config')

# ANSI color codes
RESET = "\e[0m"
BOLD = "\e[1m"
GREEN = "\e[32m"
YELLOW = "\e[33m"
BLUE = "\e[34m"
MAGENTA = "\e[35m"
CYAN = "\e[36m"
RED = "\e[31m"

# Check if color should be disabled
NO_COLOR = ENV['NO_COLOR'] || ARGV.include?('--no-color')

def colorize(text, color_code)
  return text if NO_COLOR
  "#{color_code}#{text}#{RESET}"
end

# Function to ensure string length considering ANSI codes
def visible_length(str)
  # Remove ANSI color codes for length calculation
  str.gsub(/\e\[[0-9;]*m/, '').length
end

# Function to pad string to specific length considering ANSI codes
def pad_string(str, target_length, pad_char = ' ', align = :right)
  visible_len = visible_length(str)
  padding_needed = [0, target_length - visible_len].max
  
  case align
  when :right
    return str + pad_char * padding_needed
  when :left
    return pad_char * padding_needed + str
  when :center
    left_pad = padding_needed / 2
    right_pad = padding_needed - left_pad
    return pad_char * left_pad + str + pad_char * right_pad
  end
end

# Check if day counter exists
unless File.exist?(DAY_COUNTER)
  puts "Error: Day counter file not found."
  puts "Run the setup script or start your first day with 'ccstart'."
  exit 1
end

# Get current day and calculate phases
CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i
TOTAL_DAYS = 500
DAYS_COMPLETED = CURRENT_DAY - 1
DAYS_REMAINING = TOTAL_DAYS - DAYS_COMPLETED
PERCENT_COMPLETE = (DAYS_COMPLETED.to_f / TOTAL_DAYS * 100).round(1)

# Calculate phase information
PHASE = ((CURRENT_DAY - 1) / 100) + 1
DAYS_IN_PHASE = CURRENT_DAY - ((PHASE - 1) * 100)
DAYS_REMAINING_IN_PHASE = [100 - DAYS_IN_PHASE + 1, 0].max

# Calculate week information
WEEK_OVERALL = ((CURRENT_DAY - 1) / 6) + 1
WEEK_IN_PHASE = (((CURRENT_DAY - 1) % 100) / 6) + 1
DAY_IN_WEEK = ((CURRENT_DAY - 1) % 6) + 1

# Set phase names
PHASE_NAMES = {
  1 => "Ruby Backend",
  2 => "Python Data Analysis",
  3 => "JavaScript Frontend",
  4 => "Full-Stack Projects",
  5 => "ML Finance Applications"
}

# Calculate dates
TODAY = Date.today
START_DATE = nil
if File.exist?(CONFIG_FILE) && File.read(CONFIG_FILE) =~ /"install_date":\s*"([^"]+)"/
  START_DATE = Date.parse($1) rescue nil
end

START_DATE ||= TODAY - DAYS_COMPLETED
ELAPSED_DAYS = (TODAY - START_DATE).to_i
ELAPSED_WEEKS = [ELAPSED_DAYS / 7, 1].max  # Avoid division by zero

# Calculate expected day based on 6 days/week schedule
EXPECTED_DAY = (ELAPSED_WEEKS * 6) + [ELAPSED_DAYS % 7, 6].min

# Determine if ahead or behind schedule
SCHEDULE_DIFF = DAYS_COMPLETED - EXPECTED_DAY
schedule_status = if SCHEDULE_DIFF > 0
                    colorize("#{SCHEDULE_DIFF} days ahead", GREEN)
                  elsif SCHEDULE_DIFF < 0
                    colorize("#{SCHEDULE_DIFF.abs} days behind", RED)
                  else
                    colorize("On schedule", BLUE)
                  end

# Calculate progress bar (50 chars wide)
progress_width = 50
completed_width = (DAYS_COMPLETED.to_f / TOTAL_DAYS * progress_width).round
remaining_width = progress_width - completed_width

progress_bar = "[" + 
               colorize("=" * [completed_width, 0].max, GREEN) + 
               colorize(">" * [1, remaining_width].min, YELLOW) + 
               " " * [0, remaining_width - 1].max + 
               "]"

# Calculate completion date
weeks_remaining = DAYS_REMAINING / 6
extra_days = DAYS_REMAINING % 6
completion_date = TODAY + (weeks_remaining * 7) + extra_days

# Check Git status
git_status = "Unknown"
current_streak = 0
longest_streak = 0
last_commit_date = nil

if Dir.exist?(File.join(BASE_DIR, '.git'))
  Dir.chdir(BASE_DIR) do
    # Get last commit date
    last_commit = `git log -1 --format=%cd --date=short 2>/dev/null`.strip
    last_commit_date = Date.parse(last_commit) rescue nil
    
    if last_commit_date
      # Calculate streak
      streak_output = `git log --format="%cd" --date=short | uniq`
      commit_dates = streak_output.split("\n").map { |date_str| Date.parse(date_str) rescue nil }.compact
      
      # Skip empty array
      unless commit_dates.empty?
        commit_dates.sort!
        
        # Calculate current streak
        streak = 0
        date = TODAY
        while commit_dates.include?(date)
          streak += 1
          date -= 1
        end
        
        current_streak = streak
        
        # Calculate longest streak
        longest = 0
        current = 1
        
        (1...commit_dates.length).each do |i|
          if (commit_dates[i-1] - commit_dates[i]).abs <= 1
            current += 1
          else
            longest = [longest, current].max
            current = 1
          end
        end
        
        longest_streak = [longest, current].max
      end
    end
    
    # Check if repo has changes
    has_changes = !system('git diff --quiet HEAD 2>/dev/null')
    
    if has_changes
      git_status = colorize("Changes not committed", YELLOW)
    else
      git_status = colorize("Clean", GREEN)
    end
  end
end

# Print status report
puts
box_width = 70
puts colorize("╔" + "═" * (box_width - 2) + "╗", BOLD)

# Center title with proper padding
title = "6/7 Coding Challenge Status"
title_padding = (box_width - title.length - 2) / 2
title_line = "║" + " " * title_padding + title
title_line = pad_string(title_line, box_width - 1) + "║"
puts colorize(title_line, BOLD)

puts colorize("╠" + "═" * (box_width - 2) + "╣", BOLD)

# Progress section
progress_text = "Day #{colorize(CURRENT_DAY.to_s, MAGENTA)}/#{TOTAL_DAYS} (#{colorize("#{PERCENT_COMPLETE}%", CYAN)} complete)"
progress_line = "║ 📊 " + colorize("Progress:", BOLD) + " " + progress_text
progress_line = pad_string(progress_line, box_width - 1) + "║"
puts colorize(progress_line, BOLD)

bar_line = "║ " + progress_bar + " " + "#{DAYS_COMPLETED}/#{TOTAL_DAYS} days"
bar_line = pad_string(bar_line, box_width - 1) + "║"
puts colorize(bar_line, BOLD)

puts colorize("╠" + "─" * (box_width - 2) + "╣", BOLD)

# Phase info
phase_text = "#{PHASE}/5 - #{colorize(PHASE_NAMES[PHASE], BLUE)} (Day #{DAYS_IN_PHASE}/100 in phase)"
phase_line = "║ 🔷 " + colorize("Phase:", BOLD) + " " + phase_text
phase_line = pad_string(phase_line, box_width - 1) + "║"
puts colorize(phase_line, BOLD)

week_text = "#{WEEK_OVERALL} overall (Week #{WEEK_IN_PHASE} in Phase #{PHASE})"
week_line = "║ 📅 " + colorize("Week:", BOLD) + "  " + week_text
week_line = pad_string(week_line, box_width - 1) + "║"
puts colorize(week_line, BOLD)

day_text = "#{DAY_IN_WEEK}/6 this week"
day_line = "║ 📆 " + colorize("Day:", BOLD) + "   " + day_text
day_line = pad_string(day_line, box_width - 1) + "║"
puts colorize(day_line, BOLD)

puts colorize("╠" + "─" * (box_width - 2) + "╣", BOLD)

# Schedule info
schedule_line = "║ ⏱️  " + colorize("Schedule:", BOLD) + " " + schedule_status
schedule_line = pad_string(schedule_line, box_width - 1) + "║"
puts colorize(schedule_line, BOLD)

start_text = "#{START_DATE.strftime('%Y-%m-%d')} (#{ELAPSED_DAYS} days ago)"
start_line = "║ 🚀 " + colorize("Started:", BOLD) + "  " + start_text
start_line = pad_string(start_line, box_width - 1) + "║"
puts colorize(start_line, BOLD)

completion_text = "#{completion_date.strftime('%Y-%m-%d')}"
completion_line = "║ 🏁 " + colorize("Est. finish:", BOLD) + " " + completion_text
completion_line = pad_string(completion_line, box_width - 1) + "║"
puts colorize(completion_line, BOLD)

puts colorize("╠" + "─" * (box_width - 2) + "╣", BOLD)

# Repository info
repo_line = "║ 📂 " + colorize("Repo status:", BOLD) + " " + git_status
repo_line = pad_string(repo_line, box_width - 1) + "║"
puts colorize(repo_line, BOLD)

if last_commit_date
  days_since_commit = (TODAY - last_commit_date).to_i
  commit_status = days_since_commit == 0 ? "Today" : "#{days_since_commit} days ago"
  commit_text = "#{last_commit_date.strftime('%Y-%m-%d')} (#{commit_status})"
  commit_line = "║ 📝 " + colorize("Last commit:", BOLD) + " " + commit_text
  commit_line = pad_string(commit_line, box_width - 1) + "║"
  puts colorize(commit_line, BOLD)
end

streak_text = "Current: #{current_streak} days, Longest: #{longest_streak} days"
streak_line = "║ 🔥 " + colorize("Streaks:", BOLD) + "   " + streak_text
streak_line = pad_string(streak_line, box_width - 1) + "║"
puts colorize(streak_line, BOLD)

puts colorize("╠" + "─" * (box_width - 2) + "╣", BOLD)

# Milestones
milestone_header = "║ 🏆 " + colorize("Next milestones:", BOLD)
milestone_header = pad_string(milestone_header, box_width - 1) + "║"
puts colorize(milestone_header, BOLD)

milestone_count = 0
[100, 200, 300, 400, 500].each do |milestone|
  if CURRENT_DAY <= milestone
    days_to_milestone = milestone - CURRENT_DAY + 1
    weeks = days_to_milestone / 6
    extra_days = days_to_milestone % 6
    target_date = TODAY + (weeks * 7) + extra_days
    
    milestone_name = case milestone
                     when 100 then "Phase 1 Complete"
                     when 200 then "Phase 2 Complete"
                     when 300 then "Phase 3 Complete"
                     when 400 then "Phase 4 Complete"
                     when 500 then "Challenge Complete"
                     end
    
    milestone_text = "Day #{milestone} (#{milestone_name}): #{days_to_milestone} days (#{target_date.strftime('%Y-%m-%d')})"
    milestone_line = "║   " + milestone_text
    milestone_line = pad_string(milestone_line, box_width - 1) + "║"
    puts colorize(milestone_line, BOLD)
    milestone_count += 1
  end
end

# If no milestones left
if milestone_count == 0
  complete_line = "║   No milestones remaining. Challenge complete!"
  complete_line = pad_string(complete_line, box_width - 1) + "║"
  puts colorize(complete_line, BOLD)
end

puts colorize("╚" + "═" * (box_width - 2) + "╝", BOLD)
puts
