#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Config Script
# Views and modifies configuration settings

require 'json'
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

# Parse command line arguments
require 'optparse'

options = {
  view: true,
  reset: false,
  interactive: false,
  set: nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: ccconfig [options]"
  
  opts.on("--reset", "Reset configuration to defaults") do
    options[:reset] = true
    options[:view] = false
  end
  
  opts.on("--interactive", "Update configuration interactively") do
    options[:interactive] = true
    options[:view] = false
  end
  
  opts.on("--set KEY=VALUE", "Set a specific configuration value") do |kv|
    if kv.include?('=')
      key, value = kv.split('=', 2)
      options[:set] = [key, value]
      options[:view] = false
    else
      puts colorize("Error: Invalid format for --set. Use KEY=VALUE.", RED)
      exit 1
    end
  end
end.parse!

# Reset configuration if requested
if options[:reset]
  config = CCConfig::DEFAULT_CONFIG.dup
  CCConfig.save(config)
  puts colorize("Configuration has been reset to defaults.", GREEN)
  options[:view] = true
end

# Set a specific value if requested
if options[:set]
  key_path, value = options[:set]
  config = CCConfig.load
  
  # Parse the value if it's a number, boolean, or null
  case value.downcase
  when 'true'
    value = true
  when 'false'
    value = false
  when 'null'
    value = nil
  else
    # Try to convert to number if possible
    if value =~ /^\d+$/
      value = value.to_i
    elsif value =~ /^\d+\.\d+$/
      value = value.to_f
    end
    # Otherwise keep as string
  end
  
  # Update nested configuration
  keys = key_path.split('.')
  if keys.length == 1
    config[keys[0]] = value
  else
    current = config
    keys[0..-2].each do |k|
      current[k] ||= {}
      current = current[k]
    end
    current[keys[-1]] = value
  end
  
  CCConfig.save(config)
  puts colorize("Configuration updated: #{key_path} = #{value}", GREEN)
  options[:view] = true
end

# Interactive configuration
if options[:interactive]
  puts colorize("Interactive Configuration", BOLD)
  puts "======================="
  
  config = CCConfig.load
  
  # User info
  puts "\nUser Information:"
  print "Your name (#{config['user']['name']}): "
  name = gets.strip
  config['user']['name'] = name unless name.empty?
  
  print "GitHub username (#{config['user']['github_username']}): "
  github_username = gets.strip
  config['user']['github_username'] = github_username unless github_username.empty?
  
  print "GitHub email (#{config['user']['github_email']}): "
  github_email = gets.strip
  config['user']['github_email'] = github_email unless github_email.empty?
  
  # Paths
  puts "\nDirectories:"
  print "Base directory (#{config['paths']['base_dir']}): "
  base_dir = gets.strip
  config['paths']['base_dir'] = base_dir unless base_dir.empty?
  
  print "Scripts directory (#{config['paths']['bin_dir']}): "
  bin_dir = gets.strip
  config['paths']['bin_dir'] = bin_dir unless bin_dir.empty?
  
  # Preferences
  puts "\nPreferences:"
  print "Preferred editor (#{config['preferences']['editor']}): "
  editor = gets.strip
  config['preferences']['editor'] = editor unless editor.empty?
  
  print "Use tmux? (#{config['preferences']['use_tmux'] ? 'yes' : 'no'}): "
  use_tmux = gets.strip.downcase
  if use_tmux == 'yes' || use_tmux == 'y'
    config['preferences']['use_tmux'] = true
  elsif use_tmux == 'no' || use_tmux == 'n'
    config['preferences']['use_tmux'] = false
  end
  
  print "Auto push to GitHub? (#{config['preferences']['auto_push'] ? 'yes' : 'no'}): "
  auto_push = gets.strip.downcase
  if auto_push == 'yes' || auto_push == 'y'
    config['preferences']['auto_push'] = true
  elsif auto_push == 'no' || auto_push == 'n'
    config['preferences']['auto_push'] = false
  end
  
  print "Display colors? (#{config['preferences']['display_colors'] ? 'yes' : 'no'}): "
  display_colors = gets.strip.downcase
  if display_colors == 'yes' || display_colors == 'y'
    config['preferences']['display_colors'] = true
  elsif display_colors == 'no' || display_colors == 'n'
    config['preferences']['display_colors'] = false
  end
  
  # Challenge structure
  puts "\nChallenge Structure:"
  print "Do you want to customize the challenge structure? (y/n): "
  customize_structure = gets.strip.downcase == 'y'
  
  if customize_structure
    print "Days per week (#{config['challenge']['days_per_week']}): "
    days_per_week = gets.strip
    config['challenge']['days_per_week'] = days_per_week.to_i unless days_per_week.empty?
    
    print "Days per phase (#{config['challenge']['days_per_phase']}): "
    days_per_phase = gets.strip
    config['challenge']['days_per_phase'] = days_per_phase.to_i unless days_per_phase.empty?
    
    print "Total days (#{config['challenge']['total_days']}): "
    total_days = gets.strip
    config['challenge']['total_days'] = total_days.to_i unless total_days.empty?
    
    # Phase configuration
    puts "\nPhase Names and Directories:"
    config['challenge']['phases'].each do |phase_num, phase_info|
      puts "Phase #{phase_num}:"
      print "  Name (#{phase_info['name']}): "
      name = gets.strip
      config['challenge']['phases'][phase_num]['name'] = name unless name.empty?
      
      print "  Directory (#{phase_info['dir']}): "
      dir = gets.strip
      config['challenge']['phases'][phase_num]['dir'] = dir unless dir.empty?
    end
  end
  
  # Save updated config
  CCConfig.save(config)
  puts colorize("Configuration saved successfully.", GREEN)
  options[:view] = true
end

# View configuration
if options[:view]
  config = CCConfig.load
  puts JSON.pretty_generate(config)
end