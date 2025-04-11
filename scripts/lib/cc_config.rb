#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Configuration Module
require 'json'
require 'fileutils'

module CCConfig
  # Constants
  CONFIG_FILE = File.join(ENV['HOME'], '.cc-config.json')
  DAY_COUNTER = File.join(ENV['HOME'], '.cc-current-day')
  
  # Class methods
  class << self
    def load
      if File.exist?(CONFIG_FILE)
        begin
          config = JSON.parse(File.read(CONFIG_FILE))
          deep_merge(DEFAULT_CONFIG.dup, config)
        rescue JSON::ParserError
          puts "Error: Config file is malformed, using defaults"
          DEFAULT_CONFIG.dup
        end
      else
        DEFAULT_CONFIG.dup
      end
    end

    def save(config)
      FileUtils.mkdir_p(File.dirname(CONFIG_FILE))
      File.write(CONFIG_FILE, JSON.pretty_generate(config))
    end

    def current_day
      if File.exist?(DAY_COUNTER)
        begin
          day = File.read(DAY_COUNTER).strip.to_i
          return day if day > 0
        rescue
          # Fall through to default
        end
      end
      # Default to day 1
      1
    end

    def update_day(day)
      FileUtils.mkdir_p(File.dirname(DAY_COUNTER))
      File.write(DAY_COUNTER, day.to_s)
    end

    def current_phase
      config = load
      day = current_day
      phases = config["challenge"]["phases"]
      
      # Calculate current phase based on cumulative days
      current_day_count = 0
      phases.each do |phase_num, phase_info|
        current_day_count += phase_info["days"].to_i
        return phase_num.to_i if day <= current_day_count
      end
      
      # Default to the last phase if beyond all phases
      phases.keys.map(&:to_i).max || 1
    end

    def week_in_phase
      config = load
      day = current_day
      days_per_week = config["challenge"]["days_per_week"].to_i
      phases = config["challenge"]["phases"]
      
      # Calculate days in current phase
      day_in_phase = day
      phases.each do |phase_num, phase_info|
        if phase_num.to_i < current_phase
          day_in_phase -= phase_info["days"].to_i
        end
      end
      
      # Calculate week in phase
      ((day_in_phase - 1) / days_per_week) + 1
    end

    def week_formatted
      format('%02d', week_in_phase)
    end

    def phase_dir
      config = load
      phase = current_phase
      config["challenge"]["phases"][phase.to_s]["dir"]
    end

    def base_dir
      config = load
      config["paths"]["base_dir"]
    end

    def bin_dir
      config = load
      config["paths"]["bin_dir"]
    end
    
    def log_dir
      config = load
      config["paths"]["log_dir"]
    end

    def editor
      config = load
      config["preferences"]["editor"]
    end

    def use_tmux?
      config = load
      config["preferences"]["use_tmux"]
    end

    def auto_push?
      config = load
      config["preferences"]["auto_push"]
    end

    def use_colors?
      config = load
      config["preferences"]["display_colors"]
    end
    
    def use_github?
      config = load
      config["user"]["use_github"]
    end
    
    def is_github_log_repo?
      config = load
      config["paths"]["log_repo_type"] == "github"
    end
    
    def github_log_repo
      config = load
      if config["paths"]["log_repo_type"] == "github"
        return config["paths"]["log_repo"]
      end
      return nil
    end

    def phase_days(phase_num)
      config = load
      phase = config["challenge"]["phases"][phase_num.to_s]
      phase ? phase["days"].to_i : 0
    end
    
    def total_days
      config = load
      config["challenge"]["total_days"].to_i
    end
    
    def days_per_week
      config = load
      config["challenge"]["days_per_week"].to_i
    end
    
    def phase_count
      config = load
      config["challenge"]["phases"].size
    end
    
    def phase_name(phase_num)
      config = load
      phase = config["challenge"]["phases"][phase_num.to_s]
      phase ? phase["name"] : "Unknown Phase"
    end
    
    def get_phase_and_week_for_day(day)
      config = load
      phases = config["challenge"]["phases"]
      days_per_week = config["challenge"]["days_per_week"].to_i
      
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
      
      # Calculate days in phase
      day_in_phase = day - cumulative_days
      
      # Calculate week in phase
      week_in_phase = ((day_in_phase - 1) / days_per_week) + 1
      
      {
        phase: phase_num,
        week_in_phase: week_in_phase,
        week_formatted: format('%02d', week_in_phase),
        phase_dir: phases[phase_num.to_s]["dir"],
        phase_name: phases[phase_num.to_s]["name"],
        days_in_phase: day_in_phase,
        cumulative_days: cumulative_days
      }
    end

    def detect_editor
      ['nvim', 'vim', 'code', 'emacs', 'nano'].each do |editor|
        return editor if command_exists?(editor)
      end
      ENV['EDITOR'] || 'vim'
    end

    def command_exists?(command)
      system("which #{command} > /dev/null 2>&1")
    end

    def deep_merge(original, overlay)
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
  end

  # Default configuration
  DEFAULT_CONFIG = {
    "version" => "3.1.0",
    "user" => {
      "name" => ENV['USER'] || "User",
      "github_username" => "",
      "github_email" => "",
      "use_github" => false
    },
    "paths" => {
      "base_dir" => File.join(ENV['HOME'], 'projects', '6-7-coding-challenge'),
      "bin_dir" => File.join(ENV['HOME'], 'bin'),
      "log_repo" => "",
      "log_repo_type" => "local",
      "log_dir" => ""
    },
    "preferences" => {
      "editor" => self.detect_editor,
      "use_tmux" => self.command_exists?('tmux'),
      "auto_push" => false,
      "display_colors" => true
    },
    "installation" => {
      "install_date" => Time.now.strftime('%Y-%m-%d'),
      "last_updated" => Time.now.strftime('%Y-%m-%d')
    },
    "challenge" => {
      "phases" => {
        "1" => { "name" => "500 Day Coding Challenge", "dir" => "phase1", "days" => 500 }
      },
      "days_per_week" => 6,
      "total_days" => 500
    }
  }.freeze
end
