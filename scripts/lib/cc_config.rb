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
      days_per_phase = config["challenge"]["days_per_phase"].to_i
      ((current_day - 1) / days_per_phase) + 1
    end

    def week_in_phase
      config = load
      days_per_phase = config["challenge"]["days_per_phase"].to_i
      days_per_week = config["challenge"]["days_per_week"].to_i
      (((current_day - 1) % days_per_phase) / days_per_week) + 1
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
      "editor" => self.detect_editor,
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
  }.freeze
end