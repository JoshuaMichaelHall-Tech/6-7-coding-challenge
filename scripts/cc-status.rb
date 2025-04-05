#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Status Script
# Displays challenge progress and statistics

require 'date'

# Constants
HOME_DIR = ENV['HOME']
BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')

# Check if day counter exists
unless File.exist?(DAY_COUNTER)
  puts "Error: Day counter file not found. Run setup script first."
  exit 1
end

# Get current day
CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i

# Calculate progress metrics
TOTAL_DAYS = 500
DAYS_REMAINING = TOTAL_DAYS - CURRENT_DAY + 1
PERCENT_COMPLETE = ((CURRENT_DAY - 1) * 100 / TOTAL_DAYS)

PHASE = ((CURRENT_DAY - 1) / 100) + 1
WEEK_IN_PHASE = (((CURRENT_DAY - 1) % 100) / 6) + 1
DAY_IN_WEEK = ((CURRENT_DAY - 1) % 6) + 1
WEEK_OVERALL = ((CURRENT_DAY - 1) / 6) + 1

# Determine phase name
PHASE_NAMES = {
  1 => "Ruby Backend",
  2 => "Python Data Analysis",
  3 => "JavaScript Frontend",
  4 => "Full-Stack Projects",
  5 => "ML Finance Applications"
}

PHASE_NAME = PHASE_NAMES[PHASE] || "Unknown Phase"

# Calculate completion date
begin
  completion_date = Date.today + DAYS_REMAINING
  COMPLETION_DATE = completion_date.strftime("%Y-%m-%d")
rescue
  COMPLETION_DATE = "Unknown (date calculation error)"
end

# Calculate schedule status
START_DATE = Date.new(2025, 4, 1) # Challenge start date
CURRENT_DATE = Date.today

begin
  days_elapsed = (CURRENT_DATE - START_DATE).to_i
  
  # Adjust for Sundays (don't count them in the challenge)
  weeks_elapsed = days_elapsed / 7
  sundays_elapsed = weeks_elapsed
  actual_days_elapsed = days_elapsed - sundays_elapsed
  
  # Calculate expected day vs actual day
  expected_day = actual_days_elapsed + 1
  day_difference = CURRENT_DAY - expected_day
  
  if day_difference > 0
    DAY_STATUS = "Ahead of schedule by #{day_difference} day(s)"
  elsif day_difference < 0
    DAY_STATUS = "Behind schedule by #{-day_difference} day(s)"
  else
    DAY_STATUS = "On schedule"
  end
  
  DAYS_ELAPSED = actual_days_elapsed
rescue
  DAYS_ELAPSED = "Unknown"
  DAY_STATUS = "Status calculation not supported"
end

# Console colors
if STDOUT.tty?
  BOLD = "\e[1m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN = "\e[36m"
  RESET = "\e[0m"
else
  BOLD = ""
  GREEN = ""
  YELLOW = ""
  BLUE = ""
  MAGENTA = ""
  CYAN = ""
  RESET = ""
end

# Print status with colorized output
puts "#{BOLD}╔═══════════════════════════════════════════════════╗#{RESET}"
puts "#{BOLD}║            6/7 CODING CHALLENGE STATUS             ║#{RESET}"
puts "#{BOLD}╠═══════════════════════════════════════════════════╣#{RESET}"
printf "#{BOLD}║#{RESET} #{GREEN}Current Day:#{RESET} %-37s #{BOLD}║#{RESET}\n", "#{CURRENT_DAY}/500"
printf "#{BOLD}║#{RESET} #{BLUE}Phase:#{RESET} %-43s #{BOLD}║#{RESET}\n", "#{PHASE} of 5 - #{PHASE_NAME}"
printf "#{BOLD}║#{RESET} #{MAGENTA}Week:#{RESET} %-44s #{BOLD}║#{RESET}\n", "#{WEEK_OVERALL} overall (Week #{WEEK_IN_PHASE} in Phase #{PHASE})"
printf "#{BOLD}║#{RESET} #{CYAN}Day of Week:#{RESET} %-37s #{BOLD}║#{RESET}\n", "#{DAY_IN_WEEK}/6"
printf "#{BOLD}║#{RESET} #{YELLOW}Progress:#{RESET} %-40s #{BOLD}║#{RESET}\n", "#{PERCENT_COMPLETE}% complete"
printf "#{BOLD}║#{RESET} #{GREEN}Days Elapsed:#{RESET} %-35s #{BOLD}║#{RESET}\n", "#{DAYS_ELAPSED}"
printf "#{BOLD}║#{RESET} #{GREEN}Schedule Status:#{RESET} %-32s #{BOLD}║#{RESET}\n", "#{DAY_STATUS}"
printf "#{BOLD}║#{RESET} #{BLUE}Days Remaining:#{RESET} %-34s #{BOLD}║#{RESET}\n", "#{DAYS_REMAINING}"
printf "#{BOLD}║#{RESET} #{MAGENTA}Estimated Completion:#{RESET} %-29s #{BOLD}║#{RESET}\n", "#{COMPLETION_DATE}"

# Calculate and display streaks
if Dir.exist?(File.join(BASE_DIR, '.git'))
  Dir.chdir(BASE_DIR)
  current_streak = 0
  
  begin
    yesterday = Date.today - 1
    
    while true
      yesterday_str = yesterday.strftime("%Y-%m-%d")
      has_commit = system("git log --since=\"#{yesterday_str}\" --until=\"#{yesterday_str} 23:59:59\" --pretty=format:%H | grep -q .", :out => File::NULL, :err => File::NULL)
      
      break unless has_commit
      
      current_streak += 1
      yesterday = yesterday - 1
      
      # Skip Sundays in streak calculation
      if yesterday.cwday == 7
        yesterday = yesterday - 1
      end
    end
    
    printf "#{BOLD}║#{RESET} #{CYAN}Current Streak:#{RESET} %-34s #{BOLD}║#{RESET}\n", "#{current_streak} day(s)"
  rescue
    # Ignore streak calculation errors
  end
end

# Add repository information
if Dir.exist?(File.join(BASE_DIR, '.git'))
  Dir.chdir(BASE_DIR)
  
  branch = `git branch --show-current 2>/dev/null`.strip
  branch = "Unknown" if branch.empty?
  
  last_commit = `git log -1 --pretty=format:"%h - %s" 2>/dev/null`.strip
  last_commit = "No commits yet" if last_commit.empty?
  
  last_commit_date = `git log -1 --pretty=format:"%cd" --date=short 2>/dev/null`.strip
  last_commit_date = "N/A" if last_commit_date.empty?
  
  puts "#{BOLD}╠═══════════════════════════════════════════════════╣#{RESET}"
  printf "#{BOLD}║#{RESET} #{YELLOW}Active Branch:#{RESET} %-35s #{BOLD}║#{RESET}\n", "#{branch}"
  printf "#{BOLD}║#{RESET} #{GREEN}Last Commit:#{RESET} %-37s #{BOLD}║#{RESET}\n", "#{last_commit}"
  printf "#{BOLD}║#{RESET} #{BLUE}Commit Date:#{RESET} %-36s #{BOLD}║#{RESET}\n", "#{last_commit_date}"
end

puts "#{BOLD}╚═══════════════════════════════════════════════════╝#{RESET}"
