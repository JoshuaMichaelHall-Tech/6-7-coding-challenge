#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Configuration Manager
# Allows viewing and updating challenge configuration

require 'fileutils'
require 'json'
require 'optparse'
require_relative '../lib/cc_config'

class ConfigManager
  def initialize
    @options = {
      action: :show,
      key: nil,
      value: nil
    }
  end
  
  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: ccconfig [options]"
      
      opts.on('--show', 'Show current configuration (default)') do
        @options[:action] = :show
      end
      
      opts.on('--set KEY=VALUE', 'Set a configuration value') do |kv|
        @options[:action] = :set
        key, value = kv.split('=', 2)
        @options[:key] = key
        @options[:value] = value
      end
      
      opts.on('--interactive', 'Interactive configuration') do
        @options[:action] = :interactive
      end
      
      opts.on('--reset', 'Reset to default configuration') do
        @options[:action] = :reset
      end
      
      opts.on('-h', '--help', 'Show this help message') do
        puts opts
        exit
      end
    end.parse!
  end
  
  def run
    parse_options
    
    case @options[:action]
    when :show
      show_config
    when :set
      set_config
    when :interactive
      interactive_config
    when :reset
      reset_config
    end
  end
  
  def show_config
    config = CCConfig.load
    puts JSON.pretty_generate(config)
  end
  
  def set_config
    if @options[:key].nil? || @options[:value].nil?
      puts "Error: Both key and value are required"
      exit 1
    end
    
    # Handle nested keys with dot notation
    keys = @options[:key].split('.')
    value = parse_value(@options[:value])
    
    # Build nested hash structure
    update = {}
    current = update
    
    keys[0...-1].each_with_index do |k, i|
      current[k] = {}
      current = current[k]
    end
    
    current[keys.last] = value
    
    # Update configuration
    CCConfig.update(update)
    puts "Configuration updated: #{@options[:key]} = #{value}"
  end
  
  def interactive_config
    config = CCConfig.load
    
    puts colorize("6/7 Coding Challenge Configuration", BOLD)
    puts "=" * 60
    puts
    
    # User info
    puts colorize("User Information:", BOLD)
    config["user"]["name"] = prompt("Your name", config["user"]["name"])
    config["user"]["github_username"] = prompt("GitHub username", config["user"]["github_username"]) 
    config["user"]["github_email"] = prompt("GitHub email", config["user"]["github_email"])
    puts
    
    # Paths
    puts colorize("Directories:", BOLD)
    config["paths"]["base_dir"] = prompt("Base directory", config["paths"]["base_dir"])
    config["paths"]["bin_dir"] = prompt("Scripts directory", config["paths"]["bin_dir"])
    puts
    
    # Preferences
    puts colorize("Preferences:", BOLD)
    config["preferences"]["editor"] = prompt("Preferred editor", config["preferences"]["editor"])
    
    use_tmux = config["preferences"]["use_tmux"] ? "yes" : "no"
    response = prompt("Use tmux? (yes/no)", use_tmux)
    config["preferences"]["use_tmux"] = (response.downcase == "yes" || response.downcase == "y")
    
    auto_push = config["preferences"]["auto_push"] ? "yes" : "no"
    response = prompt("Auto push to GitHub? (yes/no)", auto_push)
    config["preferences"]["auto_push"] = (response.downcase == "yes" || response.downcase == "y")
    
    display_colors = config["preferences"]["display_colors"] ? "yes" : "no"
    response = prompt("Use colored output? (yes/no)", display_colors)
    config["preferences"]["display_colors"] = (response.downcase == "yes" || response.downcase == "y")
    puts
    
    # Challenge customization
    puts colorize("Challenge Structure:", BOLD)
    puts "Note: Changing these values may affect your progress tracking."
    puts "Only modify if you're starting a new challenge or know what you're doing."
    
    response = prompt("Modify challenge structure? (yes/no)", "no")
    if response.downcase == "yes" || response.downcase == "y"
      config["challenge"]["days_per_week"] = prompt("Days per week", config["challenge"]["days_per_week"]).to_i
      config["challenge"]["days_per_phase"] = prompt("Days per phase", config["challenge"]["days_per_phase"]).to_i
      config["challenge"]["total_days"] = prompt("Total days", config["challenge"]["total_days"]).to_i
      
      # Phase configuration
      config["challenge"]["phases"].each do |phase_num, phase_info|
        puts colorize("Phase #{phase_num}:", BOLD)
        config["challenge"]["phases"][phase_num]["name"] = prompt("  Name", phase_info["name"])
        config["challenge"]["phases"][phase_num]["dir"] = prompt("  Directory", phase_info["dir"])
      end
    end
    
    # Save config
    CCConfig.save(config)
    puts colorize("\nConfiguration saved successfully!", GREEN)
  end
  
  def reset_config
    print "Are you sure you want to reset to default configuration? (y/n): "
    confirm = gets.strip.downcase
    
    if confirm == 'y' || confirm == 'yes'
      CCConfig.save(CCConfig::DEFAULT_CONFIG)
      puts "Configuration reset to defaults"
    else
      puts "Operation cancelled"
    end
  end
  
  private
  
  def parse_value(value)
    # Try to convert string values to appropriate types
    case value.downcase
    when 'true'
      true
    when 'false'
      false
    when /^\d+$/
      value.to_i
    when /^\d+\.\d+$/
      value.to_f
    else
      value
    end
  end
  
  def prompt(message, default)
    print "#{message} [#{default}]: "
    response = gets.strip
    response.empty? ? default : response
  end
  
  def colorize(text, color_code)
    return text unless CCConfig.use_colors?
    "#{color_code}#{text}#{RESET}"
  end
  
  # ANSI color codes
  RESET = "\e[0m"
  BOLD = "\e[1m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  RED = "\e[31m"
end

# Run if this script is executed directly
if __FILE__ == $PROGRAM_NAME
  ConfigManager.new.run
end