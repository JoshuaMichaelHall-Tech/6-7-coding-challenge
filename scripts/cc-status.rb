#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Status Script
# Displays current challenge status and progress

require 'date'
require_relative 'lib/cc_config'

# Load configuration
CONFIG = CCConfig.load

# Get current day info
CURRENT_DAY = CCConfig.current_day
TOTAL_DAYS = CONFIG["challenge"]["total_days"].to_i
DAYS_COMPLETED = CURRENT_DAY - 1
DAYS_REMAINING = TOTAL_DAYS - DAYS_COMPLETED
PERCENT_COMPLETE = (DAYS_COMPLETED.to_f / TOTAL_DAYS * 100).round(1)

# Get phase info
DAYS_PER_PHASE = CONFIG["challenge"]["days_per_phase"].to_i
PHASE = CCConfig.current_phase
DAYS_IN_PHASE = CURRENT_DAY - ((PHASE - 1) * DAYS_PER_PHASE)
DAYS_REMAINING_IN_PHASE = [DAYS_PER_PHASE - DAYS_IN_PHASE + 1, 0].max

# Get week info
DAYS_PER_WEEK = CONFIG["challenge"]["days_per_week"].to_i
WEEK_OVERALL = ((CURRENT_DAY - 1) / DAYS_PER_WEEK) + 1
WEEK_IN_PHASE = CCConfig.week_in_phase
DAY_IN_WEEK = ((CURRENT_DAY - 1) % DAYS_PER_WEEK) + 1

# ANSI color codes
RESET = "\e[0m"
BOLD = "\e[1m"
GREEN = "\e[32m"
YELLOW = "\e[33m"
BLUE = "\e[34m"
MAGENTA = "\e[35m"
CYAN = "\e[36m"
RED = "\e[31m"

# Helper for colorized output
def colorize(text, color_code)
  return text unless CCConfig.use_colors?
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

# Get phase names from config
PHASE_NAMES = {}
CONFIG["challenge"]["phases"].each do |phase_num, phase_info|
  PHASE_NAMES[phase_num.to_i] = phase_info["name"]
end

# Calculate dates
BASE_DIR = CCConfig.base_dir
TODAY = Date.today
START_DATE = nil

if CONFIG["installation"]["install_date"]
  START_DATE = Date.parse(CONFIG["installation"]["install_date"]) rescue nil
end

START_DATE ||= TODAY - DAYS_COMPLETED
ELAPSED_DAYS = (TODAY - START_DATE).to_i
ELAPSED_WEEKS = [ELAPSED_DAYS / 7, 1].max  # Avoid division by zero

# Calculate expected day based on 6 days/week schedule
EXPECTED_DAY = (ELAPSED_WEEKS * DAYS_PER_WEEK) + [ELAPSED_DAYS % 7, DAYS_PER_WEEK].min

# Determine if ahead or behind schedule
SCHEDULE_DIFF = DAYS_COMPLETED - EXPECTED_DAY
if SCHEDULE_DIFF > 0
  schedule_status = colorize("+#{SCHEDULE_DIFF} days ahead", GREEN)
elsif SCHEDULE_DIFF < 0
  schedule_status = colorize("#{SCHEDULE_DIFF} days behind", RED)
else
  schedule_status = colorize("On schedule", BLUE)
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
weeks_remaining = DAYS_REMAINING / DAYS_PER_WEEK
extra_days = DAYS_REMAINING % DAYS_PER_WEEK
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
title_padding = (box_width - visible_length(title) - 2) / 2
title_line = "║" + " " * title_padding + colorize(title, BOLD)
title_line = pad_string(title_line, box_width - 1) + "║"
puts title_line

puts colorize("╠" + "═" * (box_width - 2) + "╣", BOLD)

# Progress section
progress_text = "Day #{colorize(CURRENT_DAY.to_s, MAGENTA)}/#{TOTAL_DAYS} (#{colorize("#{PERCENT_COMPLETE}%", CYAN)} complete)"
progress_line = "║ 📊 " + colorize("Progress:", BOLD) + " " + progress_text
progress_line = pad_string(progress_line, box_width - 1) + "║"
puts progress_line

bar_line = "║ " + progress_bar + " " + "#{DAYS_COMPLETED}/#{TOTAL_DAYS} days"
bar_line = pad_string(bar_line, box_width - 1) + "║"
puts bar_line

puts colorize("╠" + "─" * (box_width - 2) + "╣", BOLD)

# Milestones
milestone_header = "║ 🏆 " + colorize("Next milestones:", BOLD)
milestone_header = pad_string(milestone_header, box_width - 1) + "║"
puts milestone_header

milestone_count = 0
phase_count = CONFIG["challenge"]["phases"].length

# Generate milestone days for phases
phase_milestones = []
(1..phase_count).each do |phase_num|
  milestone_day = phase_num * DAYS_PER_PHASE
  if milestone_day <= TOTAL_DAYS && CURRENT_DAY <= milestone_day
    phase_milestones << milestone_day
  end
end

# Add final milestone if not already included
unless phase_milestones.include?(TOTAL_DAYS)
  phase_milestones << TOTAL_DAYS
end

# Display milestones
phase_milestones.each do |milestone|
  if CURRENT_DAY <= milestone
    days_to_milestone = milestone - CURRENT_DAY + 1
    weeks = days_to_milestone / DAYS_PER_WEEK
    extra_days = days_to_milestone % DAYS_PER_WEEK
    target_date = TODAY + (weeks * 7) + extra_days
    
    milestone_phase = milestone / DAYS_PER_PHASE
    
    if milestone == TOTAL_DAYS
      milestone_name = "Challenge Complete"
    else
      milestone_name = "Phase #{milestone_phase} Complete"
    end
    
    milestone_text = "Day #{milestone} (#{milestone_name}): #{days_to_milestone} days (#{target_date.strftime('%Y-%m-%d')})"
    milestone_line = "║   " + milestone_text
    milestone_line = pad_string(milestone_line, box_width - 1) + "║"
    puts milestone_line
    milestone_count += 1
  end
end

# If no milestones left
if milestone_count == 0
  complete_line = "║   No milestones remaining. Challenge complete!"
  complete_line = pad_string(complete_line, box_width - 1) + "║"
  puts complete_line
end

puts colorize("╠" + "═" * (box_width - 2) + "╣", BOLD)

# Phase info
phase_text = "#{PHASE}/#{CONFIG["challenge"]["phases"].length} - #{colorize(PHASE_NAMES[PHASE], BLUE)} (Day #{DAYS_IN_PHASE}/#{DAYS_PER_PHASE} in phase)"
phase_line = "║ 🔷 " + colorize("Phase:", BOLD) + " " + phase_text
phase_line = pad_string(phase_line, box_width - 1) + "║"
puts phase_line

week_text = "#{WEEK_OVERALL} overall (Week #{WEEK_IN_PHASE} in Phase #{PHASE})"
week_line = "║ 📅 " + colorize("Week:", BOLD) + "  " + week_text
week_line = pad_string(week_line, box_width - 1) + "║"
puts week_line

day_text = "#{DAY_IN_WEEK}/#{DAYS_PER_WEEK} this week"
day_line = "║ 📆 " + colorize("Day:", BOLD) + "   " + day_text
day_line = pad_string(day_line, box_width - 1) + "║"
puts day_line

puts colorize("╠" + "─" * (box_width - 2) + "╣", BOLD)

# Schedule info
schedule_line = "║ ⏱️  " + colorize("Schedule:", BOLD) + " " + schedule_status
schedule_line = pad_string(schedule_line, box_width - 1) + "║"
puts schedule_line

start_text = "#{START_DATE.strftime('%Y-%m-%d')} (#{ELAPSED_DAYS} days ago)"
start_line = "║ 🚀 " + colorize("Started:", BOLD) + "  " + start_text
start_line = pad_string(start_line, box_width - 1) + "║"
puts start_line

completion_text = "#{completion_date.strftime('%Y-%m-%d')}"
completion_line = "║ 🏁 " + colorize("Est. finish:", BOLD) + " " + completion_text
completion_line = pad_string(completion_line, box_width - 1) + "║"
puts completion_line

puts colorize("╠" + "─" * (box_width - 2) + "╣", BOLD)

# Repository info
repo_line = "║ 📂 " + colorize("Repo status:", BOLD) + " " + git_status
repo_line = pad_string(repo_line, box_width - 1) + "║"
puts repo_line

if last_commit_date
  days_since_commit = (TODAY - last_commit_date).to_i
  commit_status = days_since_commit == 0 ? "Today" : "#{days_since_commit} days ago"
  commit_text = "#{last_commit_date.strftime('%Y-%m-%d')} (#{commit_status})"
  commit_line = "║ 📝 " + colorize("Last commit:", BOLD) + " " + commit_text
  commit_line = pad_string(commit_line, box_width - 1) + "║"
  puts commit_line
end

streak_text = "Current: #{current_streak} days, Longest: #{longest_streak} days"
streak_line = "║ 🔥 " + colorize("Streaks:", BOLD) + "   " + streak_text
streak_line = pad_string(streak_line, box_width - 1) + "║"
puts streak_line

puts colorize("╚" + "═" * (box_width - 2) + "╝", BOLD)
