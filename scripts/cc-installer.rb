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

  # Determine the source and destination paths for scripts
  def determine_script_paths
    # Find the scripts directory - where this installer is located
    installer_path = File.expand_path(__FILE__)
    @scripts_dir = File.dirname(installer_path)
    
    # Log paths if verbose
    if @options[:verbose]
      puts "Installer path: #{installer_path}"
      puts "Scripts directory: #{@scripts_dir}"
    end
  end

  # Load existing configuration if it exists
  def load_existing_config
    if File.exist?(@config_file)
      begin
        saved_config = JSON.parse(File.read(@config_file))
        deep_merge!(@config, saved_config)
      rescue JSON::ParserError
        puts "Warning: Existing config file is malformed. Using default configuration."
      end
    end
  end

  # Set up default configuration
  def setup_default_config
    # Detect default editor
    default_editor = ['nvim', 'vim', 'code', 'emacs', 'nano'].find { |editor| system("which #{editor} > /dev/null 2>&1") }
    
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
        "editor" => default_editor || ENV['EDITOR'] || 'vim',
        "use_tmux" => system("which tmux > /dev/null 2>&1"),
        "auto_push" => true,
        "display_colors" => true
      },
      "installation" => {
        "install_date" => Time.now.strftime('%Y-%m-%d'),
        "last_updated" => Time.now.strftime('%Y-%m-%d')
      },
      "challenge" => {
        "phases" => {
          "1" => { "name" => "Python Backend", "dir" => "phase1_python" },
          "2" => { "name" => "JavaScript Frontend", "dir" => "phase2_javascript" },
          "3" => { "name" => "Capstone Prep", "dir" => "phase3_capstone_prep" },
          "4" => { "name" => "Capstone", "dir" => "phase4_capstone" },
          "5" => { "name" => "Career Development", "dir" => "phase5_career_development" }
        },
        "days_per_week" => 6,
        "days_per_phase" => 100,
        "total_days" => 500
      }
    }
  end

  # Parse command line options
  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: cc-installer.rb [options]"
      
      opts.on("-i", "--install", "Perform a fresh installation") do
        @options[:action] = :install
      end
      
      opts.on("-u", "--update", "Update existing installation") do
        @options[:action] = :update
      end
      
      opts.on("--uninstall", "Uninstall the challenge") do
        @options[:action] = :uninstall
      end
      
      opts.on("--backup-logs", "Backup log files") do
        @options[:action] = :backup_logs
      end
      
      opts.on("--restore-logs", "Restore log files") do
        @options[:action] = :restore_logs
      end
      
      opts.on("-f", "--force", "Force action without confirmation") do
        @options[:force] = true
      end
      
      opts.on("-v", "--verbose", "Show verbose output") do
        @options[:verbose] = true
      end
      
      opts.on("--non-interactive", "Disable interactive prompts") do
        @options[:interactive] = false
      end
      
      opts.on("-h", "--help", "Show this help message") do
        puts opts
        exit
      end
    end.parse!
  end

  # Detect current installation status
  def detect_installation
    # Check for config file
    if File.exist?(@config_file)
      return :update
    end
    
    # Presence of any challenge scripts or directories
    challenge_scripts = Dir.glob(File.join(@default_bin_dir, 'cc-*.rb'))
    challenge_dirs = [
      @default_base_dir,
      File.join(@home_dir, 'logs', 'phase*')
    ]
    
    if !challenge_scripts.empty? || challenge_dirs.any? { |dir| Dir.exist?(dir) }
      return :update
    end
    
    # Default to new installation
    :install
  end

  # Install the challenge
  def install
    puts "Installing 6/7 Coding Challenge v#{VERSION}"
    
    # Validate prerequisites
    validate_prerequisites
    
    # Create base directories
    create_base_directories
    
    # Copy scripts to bin directory
    install_scripts
    
    # Set up configuration
    setup_configuration
    
    # Set up git repository
    setup_git_repository
    
    # Update .zshrc with aliases
    update_zshrc
    
    # Set initial day counter
    initialize_day_counter
    
    puts "Installation complete! Run 'ccstart' to begin your challenge."
  end

  # Update the existing installation
  def update
    puts "Updating 6/7 Coding Challenge v#{VERSION}"
    
    # Copy new/updated scripts
    install_scripts
    
    # Update configuration if needed
    update_configuration
    
    # Update .zshrc if needed
    update_zshrc
    
    puts "Update complete!"
  end

  # Uninstall the challenge
  def uninstall
    puts "Uninstalling 6/7 Coding Challenge"
    
    # Remove scripts, config files, etc.
    uninstall_scripts
    remove_configuration
    remove_zshrc_entries
    
    puts "Uninstallation complete."
  end

  # Backup log files
  def backup_logs
    puts "Backing up log files"
    
    # Implement log backup logic
    timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
    backup_dir = File.join(@home_dir, "cc-logs-backup-#{timestamp}")
    
    FileUtils.mkdir_p(backup_dir)
    FileUtils.cp_r(File.join(@default_base_dir, 'logs'), backup_dir)
    
    puts "Logs backed up to #{backup_dir}"
  end

  # Restore log files
  def restore_logs
    puts "Restoring log files"
    
    # Implement log restore logic
    # Prompt user to select from available backups
    backup_dirs = Dir.glob(File.join(@home_dir, "cc-logs-backup-*"))
    
    if backup_dirs.empty?
      puts "No log backups found."
      return
    end
    
    puts "Available backups:"
    backup_dirs.each_with_index do |dir, index|
      puts "#{index + 1}. #{File.basename(dir)}"
    end
    
    print "Select backup to restore (number): "
    selection = STDIN.gets.chomp.to_i
    
    if selection > 0 && selection <= backup_dirs.length
      selected_backup = backup_dirs[selection - 1]
      logs_backup = File.join(selected_backup, 'logs')
      
      if File.exist?(logs_backup)
        FileUtils.rm_rf(File.join(@default_base_dir, 'logs'))
        FileUtils.cp_r(logs_backup, @default_base_dir)
        puts "Logs restored from #{File.basename(selected_backup)}"
      else
        puts "Invalid backup selected."
      end
    else
      puts "Invalid selection."
    end
  end

  # Run the installer
  def run
    # First, parse options to potentially override config
    parse_options
    
    # Set up default configuration
    setup_default_config
    
    # Load any existing configuration
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

  # Validate system prerequisites
  def validate_prerequisites
    # Check for Ruby version
    ruby_version = `ruby -v`
    puts "Ruby version: #{ruby_version.strip}"
    
    # Check for git
    unless system("which git > /dev/null 2>&1")
      raise "Git is required but not installed."
    end
    
    # Check for tmux (optional)
    puts "tmux available: #{system("which tmux > /dev/null 2>&1")}"
  end

  # Create base directories
  def create_base_directories
    FileUtils.mkdir_p(@default_base_dir)
    FileUtils.mkdir_p(File.join(@default_base_dir, 'logs'))
    FileUtils.mkdir_p(@default_bin_dir)
  end

  # Install challenge scripts
  def install_scripts
    # Find scripts in current directory
    script_files = Dir.glob(File.join(@scripts_dir, 'cc-*.rb'))
    
    # Copy and make executable
    script_files.each do |script|
      target_path = File.join(@default_bin_dir, File.basename(script))
      FileUtils.cp(script, target_path)
      FileUtils.chmod(0755, target_path)
      puts "Installed: #{target_path}" if @options[:verbose]
    end
    
    # Also copy lib directory if it exists
    lib_source = File.join(@scripts_dir, 'lib')
    if Dir.exist?(lib_source)
      lib_target = File.join(@default_bin_dir, 'lib')
      FileUtils.rm_rf(lib_target) if Dir.exist?(lib_target)
      FileUtils.cp_r(lib_source, lib_target)
      puts "Installed lib directory: #{lib_target}" if @options[:verbose]
    end
  end

  # Set up configuration
  def setup_configuration
    # Create config file
    FileUtils.mkdir_p(File.dirname(@config_file))
    File.write(@config_file, JSON.pretty_generate(@config))
    puts "Configuration saved to #{@config_file}" if @options[:verbose]
  end

  # Update configuration
  def update_configuration
    # Load existing config
    if File.exist?(@config_file)
      existing_config = JSON.parse(File.read(@config_file))
      
      # Merge with default config, preserving existing values
      deep_merge!(@config, existing_config)
    end
    
    # Save updated configuration
    File.write(@config_file, JSON.pretty_generate(@config))
    puts "Configuration updated" if @options[:verbose]
  end

  # Set up git repository
  def setup_git_repository
    Dir.chdir(@default_base_dir) do
      # Initialize git repo if not already initialized
      unless system("git rev-parse --is-inside-work-tree > /dev/null 2>&1")
        system("git init")
        
        # Create basic .gitignore
        gitignore_content = <<~GITIGNORE
          # System Files
          .DS_Store
          .Spotlight-V100
          .Trashes
          ehthumbs.db
          Thumbs.db
          desktop.ini
          
          # Editor Files
          .idea/
          .vscode/
          *.swp
          *.swo
          
          # Logs and Temporary Files
          logs/
          *.log
          tmp/
        GITIGNORE
        
        File.write('.gitignore', gitignore_content)
        system("git add .")
        system("git commit -m 'Initial commit for 6/7 Coding Challenge'")
      end
    end
  end

  # Update .zshrc
  def update_zshrc
    # Aliases for challenge scripts
    aliases = [
      "# 6/7 Coding Challenge aliases",
      "alias ccstart='ruby #{@default_bin_dir}/cc-start-day.rb'",
      "alias cclog='ruby #{@default_bin_dir}/cc-log-progress.rb'",
      "alias ccpush='ruby #{@default_bin_dir}/cc-push-updates.rb'",
      "alias ccstatus='ruby #{@default_bin_dir}/cc-status.rb'",
      "alias ccconfig='ruby #{@default_bin_dir}/cc-config.rb'",
      "alias ccupdate='ruby #{@default_bin_dir}/cc-update.rb'",
      "alias ccuninstall='ruby #{@default_bin_dir}/cc-uninstall.rb'"
    ]
    
    # Read current .zshrc
    zshrc_content = File.read(@zshrc_file)
    
    # Check if aliases already exist
    if zshrc_content.include?(aliases[0])
      # Remove existing aliases
      zshrc_content = zshrc_content.gsub(/# 6\/7 Coding Challenge aliases[\s\S]*?(?=\n\n|\z)/, '')
    end
    
    # Append new aliases
    zshrc_content += "\n\n" + aliases.join("\n")
    
    # Write back to .zshrc
    File.write(@zshrc_file, zshrc_content)
    puts "Updated .zshrc with challenge aliases" if @options[:verbose]
  end

  # Initialize day counter
  def initialize_day_counter
    File.write(@day_counter, "1")
    puts "Initialized day counter to 1" if @options[:verbose]
  end

  # Uninstall challenge scripts
  def uninstall_scripts
    # Remove challenge scripts from bin directory
    Dir.glob(File.join(@default_bin_dir, 'cc-*.rb')).each do |script|
      FileUtils.rm_f(script)
    end
    
    # Remove lib directory
    FileUtils.rm_rf(File.join(@default_bin_dir, 'lib'))
  end

  # Remove configuration
  def remove_configuration
    FileUtils.rm_f(@config_file)
    FileUtils.rm_f(@day_counter)
  end

  # Remove .zshrc entries
  def remove_zshrc_entries
    # Read .zshrc
    zshrc_content = File.read(@zshrc_file)
    
    # Remove challenge-related aliases
    zshrc_content = zshrc_content.gsub(/# 6\/7 Coding Challenge aliases[\s\S]*?(?=\n\n|\z)/, '')
    
    # Write back to .zshrc
    File.write(@zshrc_file, zshrc_content)
  end

  # Perform deep merge of configuration
  def deep_merge!(original, overlay)
    overlay.each do |key, value|
      if value.is_a?(Hash) && original[key].is_a?(Hash)
        deep_merge!(original[key], value)
      else
        original[key] = value
      end
    end
  end
end

# Run the installer if this script is executed directly
if __FILE__ == $PROGRAM_NAME
  CodingChallengeInstaller.new.run
end