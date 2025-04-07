#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Status Script
# Displays current challenge status and progress

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
MAGENTA = "\e[35m"
CYAN = "\e[36m"
RED = "\e[31m"

# Helper for colorized output
def colorize(text, color_code)
  return text unless CCConfig.use_colors?
  "#{color_code}#{text}#{RESET}"
end

# Get current day and challenge parameters
CURRENT_DAY = CCConfig.current_day
TOTAL_DAYS = CONFIG["challenge"]["total_days"].to_i
DAYS_COMPLETED = CURRENT_DAY - 1
DAYS_REMAINING = TOTAL_DAYS - DAYS_COMPLETED
PERCENT_COMPLETE = (DAYS_COMPLETED.to_f / TOTAL_DAYS * 100).round(1)

# Calculate phase information
DAYS_PER_PHASE = CONFIG["challenge"]["days_per_phase"].to_i
PHASE = CCConfig.current_phase
DAYS_IN_PHASE = CURRENT_DAY - ((PHASE - 1) * DAYS_PER_PHASE)
DAYS_REMAINING_IN_PHASE = [DAYS_PER_PHASE - DAYS_IN_PHASE + 1, 0].max

# Calculate week information
DAYS_PER_WEEK = CONFIG["challenge"]["days_per_week"].to_i
WEEK_OVERALL = ((CURRENT_DAY - 1) / DAYS_PER_WEEK) + 1
WEEK_IN_PHASE = CCConfig.week_in_phase
DAY_IN_WEEK = ((CURRENT_DAY - 1) % DAYS_PER_WEEK) + 1

# Get phase names from config
PHASE_NAMES = {}
CONFIG["challenge"]["phases"].each do |phase_num, phase_info|
  PHASE_NAMES[phase_num.to_i] = phase_info["name"]
end

# Calculate dates
BASE_DIR = CCConfig.base_dir
START_DATE = nil
if CONFIG["installation"]["install_date"]
  START_DATE = Date.parse(CONFIG["installation"]["install_date"]) rescue nil
end

START_DATE ||= Date.today - DAYS_COMPLETED
TODAY = Date.today
ELAPSED_DAYS = (TODAY - START_DATE).to_i
ELAPSED_WEEKS = ELAPSED_DAYS / 7

# Calculate expected day based on configured days/week schedule
EXPECTED_DAY = (ELAPSED_WEEKS * DAYS_PER_WEEK) + [ELAPSED_DAYS % 7, DAYS_PER_WEEK].min

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
               colorize("=" * completed_width, GREEN) + 
               colorize(">" * [1, remaining_width].min, YELLOW) + 
               " " * [0, remaining_width - 1].max + 
               "]"

# Calculate completion date
if SCHEDULE_DIFF >= 0
  # If on schedule or ahead, use configured days/week
  weeks_remaining = DAYS_REMAINING / DAYS_PER_WEEK
  extra_days = DAYS_REMAINING % DAYS_PER_WEEK
  completion_date = TODAY + (weeks_remaining * 7) + extra_days
else
  # If behind schedule, use current pace to estimate
  days_per_week = DAYS_COMPLETED.to_f / ELAPSED_WEEKS
  return TODAY if days_per_week <= 0
  
  weeks_remaining = (DAYS_REMAINING / days_per_week).ceil
  completion_date = TODAY + (weeks_remaining * 7)
end

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
puts colorize("6/7 Coding Challenge Status", BOLD)
puts "=" * 60
puts

puts "#{colorize("Current Progress:", BOLD)} Day #{colorize(CURRENT_DAY.to_s, MAGENTA)}/#{TOTAL_DAYS} (#{colorize("#{PERCENT_COMPLETE}%", CYAN)} complete)"
puts "#{progress_bar} #{DAYS_COMPLETED}/#{TOTAL_DAYS} days"
puts

phase_count = CONFIG["challenge"]["phases"].keys.length
puts "#{colorize("Phase:", BOLD)} #{PHASE}/#{phase_count} - #{colorize(PHASE_NAMES[PHASE], BLUE)} (Day #{DAYS_IN_PHASE}/#{DAYS_PER_PHASE} in this phase)"
puts "#{colorize("Week:", BOLD)} #{WEEK_OVERALL} overall (Week #{WEEK_IN_PHASE} in Phase #{PHASE})"
puts "#{colorize("Day:", BOLD)} #{DAY_IN_WEEK}/#{DAYS_PER_WEEK} this week"
puts

puts "#{colorize("Schedule:", BOLD)} #{schedule_status}"
puts "#{colorize("Started:", BOLD)} #{START_DATE.strftime('%Y-%m-%d')} (#{ELAPSED_DAYS} days ago)"
puts "#{colorize("Estimated completion:", BOLD)} #{completion_date.strftime('%Y-%m-%d')}"
puts

# Display GitHub info if configured
if CONFIG["user"]["github_username"] && !CONFIG["user"]["github_username"].empty?
  puts "#{colorize("GitHub:", BOLD)} #{CONFIG["user"]["github_username"]}"
end

puts "#{colorize("Repository Status:", BOLD)} #{git_status}"
if last_commit_date
  days_since_commit = (TODAY - last_commit_date).to_i
  commit_status = days_since_commit == 0 ? "Today" : "#{days_since_commit} days ago"
  puts "#{colorize("Last commit:", BOLD)} #{last_commit_date.strftime('%Y-%m-%d')} (#{commit_status})"
end
puts "#{colorize("Current streak:", BOLD)} #{current_streak} days"
puts "#{colorize("Longest streak:", BOLD)} #{longest_streak} days"
puts

puts "#{colorize("Next milestones:", BOLD)}"
phase_milestones = []

# Generate milestones for each phase completion
CONFIG["challenge"]["phases"].keys.map(&:to_i).sort.each do |phase_num|
  milestone_day = ((phase_num) * DAYS_PER_PHASE)
  if milestone_day <= TOTAL_DAYS && CURRENT_DAY <= milestone_day
    phase_milestones << milestone_day
  end
end

# Add the final milestone if not already included
unless phase_milestones.include?(TOTAL_DAYS)
  phase_milestones << TOTAL_DAYS
end

phase_milestones.each do |milestone|
  if CURRENT_DAY <= milestone
    days_to_milestone = milestone - CURRENT_DAY + 1
    weeks = days_to_milestone / DAYS_PER_WEEK
    extra_days = days_to_milestone % DAYS_PER_WEEK
    target_date = TODAY + (weeks * 7) + extra_days
    
    if milestone == TOTAL_DAYS
      milestone_name = "Challenge Complete"
    else
      phase_num = milestone / DAYS_PER_PHASE
      milestone_name = "Phase #{phase_num} Complete"
    end
    
    puts "  Day #{milestone} (#{milestone_name}): #{days_to_milestone} days remaining (#{target_date.strftime('%Y-%m-%d')})"
  end
end

# Display configuration info
puts "\n#{colorize("Configuration:", BOLD)}"
puts "#{colorize("Base Directory:", BOLD)} #{CCConfig.base_dir}"
puts "#{colorize("Editor:", BOLD)} #{CCConfig.editor}"
puts "#{colorize("Auto Push:", BOLD)} #{CCConfig.auto_push? ? 'Enabled' : 'Disabled'}"
puts "#{colorize("Use Tmux:", BOLD)} #{CCConfig.use_tmux? ? 'Enabled' : 'Disabled'}"
puts "\nRun #{colorize('ccconfig', CYAN)} to view or update your configuration."
puts