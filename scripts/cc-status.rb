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
START_DATE = nil
if File.exist?(CONFIG_FILE) && File.read(CONFIG_FILE) =~ /"install_date":\s*"([^"]+)"/
  START_DATE = Date.parse($1) rescue nil
end

START_DATE ||= Date.today - DAYS_COMPLETED
TODAY = Date.today
ELAPSED_DAYS = (TODAY - START_DATE).to_i
ELAPSED_WEEKS = ELAPSED_DAYS / 7

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
               colorize("=" * completed_width, GREEN) + 
               colorize(">" * [1, remaining_width].min, YELLOW) + 
               " " * [0, remaining_width - 1].max + 
               "]"

# Calculate completion date
if SCHEDULE_DIFF >= 0
  # If on schedule or ahead, use 6 days/week
  weeks_remaining = DAYS_REMAINING / 6
  extra_days = DAYS_REMAINING % 6
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

puts "#{colorize("Phase:", BOLD)} #{PHASE}/5 - #{colorize(PHASE_NAMES[PHASE], BLUE)} (Day #{DAYS_IN_PHASE}/100 in this phase)"
puts "#{colorize("Week:", BOLD)} #{WEEK_OVERALL} overall (Week #{WEEK_IN_PHASE} in Phase #{PHASE})"
puts "#{colorize("Day:", BOLD)} #{DAY_IN_WEEK}/6 this week"
puts

puts "#{colorize("Schedule:", BOLD)} #{schedule_status}"
puts "#{colorize("Started:", BOLD)} #{START_DATE.strftime('%Y-%m-%d')} (#{ELAPSED_DAYS} days ago)"
puts "#{colorize("Estimated completion:", BOLD)} #{completion_date.strftime('%Y-%m-%d')}"
puts

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
    
    puts "  Day #{milestone} (#{milestone_name}): #{days_to_milestone} days remaining (#{target_date.strftime('%Y-%m-%d')})"
  end
end
puts
