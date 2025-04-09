#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Installer Script
require 'fileutils'
require 'optparse'
require 'json'

class CodingChallengeInstaller
  VERSION = '3.0.0'
  
  # Initialize paths
  def initialize
    @home_dir = ENV['HOME']
    @default_base_dir = File.join(@home_dir, 'projects', '6-7-coding-challenge')
    @default_bin_dir = File.join(@home_dir, 'bin')
    @config_file = File.join(@home_dir, '.cc-config.json')
    @day_counter = File.join(@home_dir, '.cc-current-day')
    @zshrc_file = File.join(@home_dir, '.zshrc')
    
    @options = {
      action: :detect,
      force: false,
      verbose: false,
      interactive: true
    }
    
    setup_default_config
    determine_script_paths
  end

  # Set up default configuration
  def setup_default_config
    @config = {
      "version" => VERSION,
      "user" => {
        "name" => ENV['USER'] || "User",
        "github_username" => "",
        "github_email" => ""
      },
      "paths" => {
        "base_dir" => @default_base_dir,
        "bin_dir" => @default_bin_dir
      },
      "preferences" => {
        "editor" => detect_editor,
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
    }
  end

  # Run the installer
  def run
    parse_options
    load_existing_config
    
    case @options[:action]
    when :install
      install
    when :update
      update
    when :uninstall
      uninstall
    when :backup_logs
      backup_logs
    when :restore_logs
      restore_logs
    else
      @options[:action] = detect_installation
      run  # Recurse with detected action
    end
  end

  private

  # Helper methods
  def detect_editor
    ['nvim', 'vim', 'code', 'emacs', 'nano'].each do |editor|
      return editor if command_exists?(editor)
    end
    ENV['EDITOR'] || 'vim'
  end

  def command_exists?(command)
    system("which #{command} > /dev/null 2>&1")
  end

  def determine_script_paths
    @current_dir = File.dirname(File.expand_path(__FILE__))
    
    if File.exist?(File.join(@current_dir, '..', 'README.md')) || 
       File.exist?(File.join(@current_dir, 'README.md'))
      @repo_dir = File.exist?(File.join(@current_dir, '..', 'README.md')) ? 
                  File.expand_path(File.join(@current_dir, '..')) : 
                  @current_dir
      @scripts_dir = File.join(@repo_dir, 'scripts')
      @running_from_repo = true
    else
      @scripts_dir = @current_dir
      @running_from_repo = false
    end
  end

  def load_existing_config
    if File.exist?(@config_file)
      begin
        saved_config = JSON.parse(File.read(@config_file))
        deep_merge!(@config, saved_config)
      rescue JSON::ParserError
        puts_warning "Config file is malformed, using defaults"
      end
    end
  end

  def deep_merge!(original, overlay)
    overlay.each do |key, value|
      if value.is_a?(Hash) && original[key].is_a?(Hash)
        deep_merge!(original[key], value)
      else
        original[key] = value
      end
    end
  end

  # Main installation methods would follow...
  # (The rest of the class implementation would continue here)
end

# Run the installer if this script is executed directly
if __FILE__ == $PROGRAM_NAME
  CodingChallengeInstaller.new.run
end