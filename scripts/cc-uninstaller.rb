#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Complete Uninstaller
# This script will remove all components of the 6/7 Coding Challenge

require 'fileutils'
require 'optparse'

class CodingChallengeUninstaller
  # Paths
  HOME_DIR = ENV['HOME']
  BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
  BIN_DIR = File.join(HOME_DIR, 'bin')
  CONFIG_FILE = File.join(HOME_DIR, '.cc-config')
  DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
  ZSHRC_FILE = File.join(HOME_DIR, '.zshrc')

  # Aliases marker
  ALIASES_MARKER = '# 6/7 Coding Challenge aliases'

  def initialize
    @options = {
      force: false,
      verbose: false,
      preserve_code: true,
      preserve_progress: true
    }
  end

  # Parse command line options
  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
      
      opts.on('-f', '--force', 'Force removal without confirmation prompts') do
        @options[:force] = true
      end
      
      opts.on('-v', '--verbose', 'Show detailed output') do
        @options[:verbose] = true
      end
      
      opts.on('--remove-code', 'Remove project directory with all code and logs') do
        @options[:preserve_code] = false
      end
      
      opts.on('--remove-progress', 'Remove day counter (resets progress)') do
        @options[:preserve_progress] = false
      end
      
      opts.on('-h', '--help', 'Show this help message') do
        puts opts
        exit
      end
    end.parse!
  end

  # Run the uninstaller
  def run
    parse_options
    
    puts "===== 6/7 Coding Challenge Uninstaller ====="
    
    unless @options[:force]
      print "Are you sure you want to uninstall the 6/7 Coding Challenge? (y/n): "
      response = STDIN.gets.strip.downcase
      unless response == 'y'
        puts "Uninstallation canceled."
        exit
      end
    end
    
    # Remove scripts
    remove_scripts
    
    # Remove aliases
    remove_aliases
    
    # Remove config file
    remove_config_file
    
    # Confirm progress preservation
    if @options[:preserve_progress] && !@options[:force] && File.exist?(DAY_COUNTER)
      current_day = File.read(DAY_COUNTER).strip rescue '1'
      print "Keep your progress (currently on day #{current_day})? (y/n): "
      @options[:preserve_progress] = STDIN.gets.strip.downcase == 'y'
    end
    
    # Remove day counter
    remove_day_counter unless @options[:preserve_progress]
    
    # Confirm code preservation
    if @options[:preserve_code] && !@options[:force] && Dir.exist?(BASE_DIR)
      print "Keep your project directory with all code and logs? (y/n): "
      @options[:preserve_code] = STDIN.gets.strip.downcase == 'y'
    end
    
    # Remove project directory
    remove_project_directory unless @options[:preserve_code]
    
    # Final message
    puts "\nUninstallation complete!"
    
    if @options[:preserve_code]
      puts "Your code and logs have been preserved at: #{BASE_DIR}"
    end
    
    if @options[:preserve_progress]
      puts "Your progress (day counter) has been preserved."
    end
    
    puts "To complete the process, you may want to run: source ~/.zshrc"
  end

  # Remove all scripts
  def remove_scripts
    puts "Removing scripts..."
    
    scripts_found = false
    Dir.glob(File.join(BIN_DIR, "cc-*.rb")).each do |script|
      File.delete(script)
      puts "  Deleted: #{script}" if @options[:verbose]
      scripts_found = true
    end
    
    if scripts_found
      puts "All scripts removed successfully."
    else
      puts "No scripts found."
    end
  end

  # Remove aliases from .zshrc
  def remove_aliases
    puts "Removing aliases from .zshrc..."
    
    if File.exist?(ZSHRC_FILE)
      zshrc_content = File.read(ZSHRC_FILE)
      
      if zshrc_content.include?(ALIASES_MARKER)
        marker_index = zshrc_content.index(ALIASES_MARKER)
        next_line_index = zshrc_content.index("\n", marker_index + ALIASES_MARKER.length)
        
        if next_line_index
          # Find all aliases
          new_content = zshrc_content.lines
          alias_lines = []
          
          new_content.each_with_index do |line, index|
            if line.include?(ALIASES_MARKER) || line.start_with?('alias cc')
              alias_lines << index
            end
          end
          
          # Remove the lines in reverse order to avoid index changes
          alias_lines.reverse.each do |index|
            new_content.delete_at(index)
          end
          
          # Write back
          File.write(ZSHRC_FILE, new_content.join)
          puts "Aliases removed from .zshrc."
        else
          puts "No aliases found in .zshrc."
        end
      else
        puts "No aliases marker found in .zshrc."
      end
    else
      puts "  .zshrc file not found."
    end
  end

  # Remove configuration file
  def remove_config_file
    puts "Removing configuration file..."
    
    if File.exist?(CONFIG_FILE)
      File.delete(CONFIG_FILE)
      puts "  Configuration file removed."
    else
      puts "  Configuration file not found."
    end
  end

  # Remove day counter
  def remove_day_counter
    puts "Removing day counter..."
    
    if File.exist?(DAY_COUNTER)
      File.delete(DAY_COUNTER)
      puts "  Day counter removed. Your progress has been reset."
    else
      puts "  Day counter not found."
    end
  end

  # Remove project directory
  def remove_project_directory
    puts "Removing project directory..."
    
    if Dir.exist?(BASE_DIR)
      if @options[:force]
        FileUtils.rm_rf(BASE_DIR)
        puts "  Project directory removed."
      else
        print "WARNING: This will delete all your code and logs. Are you absolutely sure? (yes/no): "
        response = STDIN.gets.strip.downcase
        
        if response == 'yes'
          FileUtils.rm_rf(BASE_DIR)
          puts "  Project directory removed."
        else
          puts "  Project directory preserved."
        end
      end
    else
      puts "  Project directory not found."
    end
  end
end

# Run the uninstaller
CodingChallengeUninstaller.new.run
