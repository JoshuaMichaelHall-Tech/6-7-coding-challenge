#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Configuration Module
# Handles loading, saving, and updating configuration

require 'json'
require 'fileutils'

module CCConfig
  CONFIG_FILE = File.join(ENV['HOME'], '.cc-config.json')
  DAY_COUNTER = File.join(ENV['HOME'], '.cc-current-day')
  
  # ANSI color codes
  RESET = "\e[0m"
  BOLD = "\e[1m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN = "\e[36m"
  RED = "\e[31m"
  
  DEFAULT_CONFIG = {
    "version" => "3.0.0",
    "user" => {
      "name" => ENV['USER'] || "User",
      "github_username" => "",
      "github_email" => ""
    },
    "paths" => {
      "base_dir" => File.join(ENV['HOME'], 'projects', '6-7-coding-challenge'),
      "bin_dir" => File.join(ENV['HOME'], 'bin')
    },
    "preferences" => {
      "editor" => self.detect_editor(),
      "use_tmux" => self.command_exists?('tmux'),
      "auto_push" => true,
      "display_colors" => true
    },
    "installation" => {
      "install_date" => Time.now.strftime('%Y-%m-%d'),
      "last_updated" => Time.now.strftime('%Y-%m-%d')
    },
    "challenge" => {
      "phases" => {
        "1" => { "name" => "Ruby Backend", "dir" => "phase1_ruby" },
        "2" => { "name" => "Python Data Analysis", "dir" => "phase2_python" },
        "3" => { "name" => "JavaScript Frontend", "dir" => "phase3_javascript" },
        "4" => { "name" => "Full-Stack Projects", "dir" => "phase4_fullstack" },
        "5" => { "name" => "ML Finance Applications", "dir" => "phase5_ml_finance" }
      },
      "days_per_week" => 6,
      "days_per_phase" => 100,
      "total_days" => 500
    }
  }
  
  # Detect installed editor
  def self.detect_editor
    ['nvim', 'vim', 'code', 'emacs', 'nano'].each do |editor|
      return editor if command_exists?(editor)
    end
    return ENV['EDITOR'] || 'vim'
  end
  
  # Check if a command exists
  def self.command_exists?(command)
    system("which #{command} > /dev/null 2>&1")
  end
  
  # Load configuration file
  def self.load
    if File.exist?(CONFIG_FILE)
      begin
        config = JSON.parse(File.read(CONFIG_FILE))
        # Merge with defaults to ensure all keys exist
        deep_merge(DEFAULT_CONFIG.dup, config)
      rescue JSON::ParserError
        puts "Error: Config file is malformed, using defaults"
        DEFAULT_CONFIG.dup
      end
    else
      DEFAULT_CONFIG.dup
    end
  end
  
  # Save configuration to file
  def self.save(config)
    # Ensure directory exists
    FileUtils.mkdir_p(File.dirname(CONFIG_FILE))
    File.write(CONFIG_FILE, JSON.pretty_generate(config))
  end
  
  # Deep merge two hashes
  def self.deep_merge(original, overlay)
    merged = original.dup
    
    overlay.each do |key, value|
      if value.is_a?(Hash) && original[key].is_a?(Hash)
        merged[key] = deep_merge(original[key], value)
      else
        merged[key] = value
      end
    end
    
    merged
  end
  
  # Update specific config values
  def self.update(updates)
    config = load
    config = deep_merge(config, updates)
    config["installation"]["last_updated"] = Time.now.strftime('%Y-%m-%d')
    save(config)
    config
  end
  
  # Get current day from counter file
  def self.current_day
    unless File.exist?(DAY_COUNTER)
      File.write(DAY_COUNTER, "1")
      return 1
    end
    
    File.read(DAY_COUNTER).strip.to_i
  end
  
  # Update day counter
  def self.update_day(day)
    File.write(DAY_COUNTER, day.to_s)
  end
  
  # Calculate phase from day
  def self.current_phase
    config = load
    days_per_phase = config["challenge"]["days_per_phase"].to_i
    ((current_day - 1) / days_per_phase) + 1
  end
  
  # Calculate week from day
  def self.current_week
    config = load
    days_per_week = config["challenge"]["days_per_week"].to_i
    ((current_day - 1) / days_per_week) + 1
  end
  
  # Get week in phase
  def self.week_in_phase
    config = load
    days_per_phase = config["challenge"]["days_per_phase"].to_i
    days_per_week = config["challenge"]["days_per_week"].to_i
    
    (((current_day - 1) % days_per_phase) / days_per_week) + 1
  end
  
  # Get formatted week (with leading zero)
  def self.week_formatted
    format('%02d', week_in_phase)
  end
  
  # Get phase directory
  def self.phase_dir
    config = load
    phase = current_phase
    config["challenge"]["phases"][phase.to_s]["dir"]
  end
  
  # Get base directory
  def self.base_dir
    config = load
    config["paths"]["base_dir"]
  end
  
  # Get bin directory
  def self.bin_dir
    config = load
    config["paths"]["bin_dir"]
  end
  
  # Get preferred editor
  def self.editor
    config = load
    config["preferences"]["editor"]
  end
  
  # Should use tmux?
  def self.use_tmux?
    config = load
    config["preferences"]["use_tmux"]
  end
  
  # Should auto push?
  def self.auto_push?
    config = load
    config["preferences"]["auto_push"]
  end
  
  # Should use colors?
  def self.use_colors?
    config = load
    config["preferences"]["display_colors"]
  end
end