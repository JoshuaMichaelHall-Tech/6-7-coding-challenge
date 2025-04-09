#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Configuration Module
require 'json'
require 'fileutils'

module CCConfig
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

    # Other helper methods...
  end

  # Constants
  CONFIG_FILE = File.join(ENV['HOME'], '.cc-config.json')
  DAY_COUNTER = File.join(ENV['HOME'], '.cc-current-day')
  
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
      "editor" => detect_editor(),
      "use_tmux" => command_exists?('tmux'),
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