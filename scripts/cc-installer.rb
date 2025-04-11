#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Installer Script
require 'fileutils'
require 'optparse'
require 'json'

class CodingChallengeInstaller
  VERSION = '3.1.1'
  
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
        "github_email" => "",
        "use_github" => false
      },
      "paths" => {
        "base_dir" => @default_base_dir,
        "bin_dir" => @default_bin_dir,
        "log_repo" => "",       # Repository name or local directory
        "log_repo_type" => "local", # "local" or "github"
        "log_dir" => ""         # Local directory for logs (might be same as base_dir)
      },
      "preferences" => {
        "editor" => default_editor || ENV['EDITOR'] || 'vim',
        "use_tmux" => system("which tmux > /dev/null 2>&1"),
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

  # Install the challenge with interactive configuration
  def install
    puts "Installing 6/7 Coding Challenge v#{VERSION}"
    
    # Validate prerequisites
    validate_prerequisites
    
    if @options[:interactive]
      gather_user_information
      gather_path_information
      gather_preferences
      gather_challenge_structure
    end
    
    # Create base directories
    create_base_directories
    
    # Copy scripts to bin directory
    install_scripts
    
    # Generate config module
    generate_config_module
    
    # Set up configuration
    setup_configuration
    
    # Set up git repository if using GitHub
    setup_git_repository if @config["user"]["use_github"]
    
    # Update .zshrc with aliases
    update_zshrc
    
    # Set initial day counter
    initialize_day_counter
    
    puts "Installation complete! Run 'ccstart' to begin your challenge."
  end

  # Gather user information interactively
  def gather_user_information
    puts "\n===== User Information ====="
    
    print "Your name (#{@config['user']['name']}): "
    name = gets.strip
    @config['user']['name'] = name unless name.empty?
    
    print "Would you like to integrate with GitHub? (y/n): "
    use_github = gets.strip.downcase == 'y'
    @config['user']['use_github'] = use_github
    
    if use_github
      print "GitHub username: "
      github_username = gets.strip
      @config['user']['github_username'] = github_username unless github_username.empty?
      
      print "GitHub email (for commits): "
      github_email = gets.strip
      @config['user']['github_email'] = github_email unless github_email.empty?
    end
  end

  # Gather path information interactively
  def gather_path_information
    puts "\n===== Directory Paths ====="
    
    print "Base project directory (#{@config['paths']['base_dir']}): "
    base_dir = gets.strip
    @config['paths']['base_dir'] = base_dir unless base_dir.empty?
    
    print "Scripts directory (#{@config['paths']['bin_dir']}): "
    bin_dir = gets.strip
    @config['paths']['bin_dir'] = bin_dir unless bin_dir.empty?
    
    print "Would you like to log days in a different repository? (y/n): "
    use_different_repo = gets.strip.downcase == 'y'
    
    if use_different_repo
      if @config['user']['use_github']
        print "Do you want to use (1) a local directory or (2) a GitHub repository? (1/2): "
        repo_type = gets.strip
        
        if repo_type == "2"
          # GitHub repository
          print "GitHub repository name (e.g., username/repo-name): "
          repo_name = gets.strip
          
          # Store the repo name, not the URL
          @config['paths']['log_repo'] = repo_name
          @config['paths']['log_repo_type'] = "github"
          
          # Derive local path - create a sensible default in a subdirectory
          default_log_dir = File.join(@config['paths']['base_dir'], "logs-repo")
          print "Local directory for logs (#{default_log_dir}): "
          log_dir = gets.strip
          @config['paths']['log_dir'] = log_dir.empty? ? default_log_dir : log_dir
        else
          # Local directory
          print "Path to local directory for logs: "
          log_dir = gets.strip
          @config['paths']['log_repo'] = log_dir unless log_dir.empty?
          @config['paths']['log_repo_type'] = "local"
          @config['paths']['log_dir'] = @config['paths']['log_repo']
        end
      else
        # Not using GitHub, so logs must be in a local directory
        print "Path to local directory for logs: "
        log_dir = gets.strip
        @config['paths']['log_repo'] = log_dir unless log_dir.empty?
        @config['paths']['log_repo_type'] = "local"
        @config['paths']['log_dir'] = @config['paths']['log_repo']
      end
    else
      # Use main repository for logs
      @config['paths']['log_repo'] = ""
      @config['paths']['log_repo_type'] = "local"
      @config['paths']['log_dir'] = @config['paths']['base_dir']
    end
  end

  # Gather user preferences interactively
  def gather_preferences
    puts "\n===== User Preferences ====="
    
    print "Preferred code editor (#{@config['preferences']['editor']}): "
    editor = gets.strip
    @config['preferences']['editor'] = editor unless editor.empty?
    
    print "Use tmux for terminal sessions? (y/n) [#{@config['preferences']['use_tmux'] ? 'y' : 'n'}]: "
    use_tmux = gets.strip.downcase
    @config['preferences']['use_tmux'] = (use_tmux == 'y') unless use_tmux.empty?
    
    if @config['user']['use_github']
      print "Automatically push changes to GitHub? (y/n) [#{@config['preferences']['auto_push'] ? 'y' : 'n'}]: "
      auto_push = gets.strip.downcase
      @config['preferences']['auto_push'] = (auto_push == 'y') unless auto_push.empty?
    else
      @config['preferences']['auto_push'] = false
    end
    
    print "Display colored output in terminal? (y/n) [#{@config['preferences']['display_colors'] ? 'y' : 'n'}]: "
    display_colors = gets.strip.downcase
    @config['preferences']['display_colors'] = (display_colors == 'y') unless display_colors.empty?
  end

  # Gather challenge structure interactively
  def gather_challenge_structure
    puts "\n===== Challenge Structure ====="
    
    print "Number of coding days per week (#{@config['challenge']['days_per_week']}): "
    days_per_week = gets.strip
    @config['challenge']['days_per_week'] = days_per_week.to_i unless days_per_week.empty?
    
    # Ask for number of phases explicitly
    print "How many phases would you like to have in your challenge? (1-10, default: 1): "
    num_phases = gets.strip
    num_phases = num_phases.empty? ? 1 : [num_phases.to_i, 1].max
    
    # Clear existing phases and gather new ones
    @config['challenge']['phases'] = {}
    total_days = 0
    
    if num_phases == 1
      # Simple setup for single phase
      print "Name for your phase (default: 500 Day Coding Challenge): "
      name = gets.strip
      name = "500 Day Coding Challenge" if name.empty?
      
      print "Directory name (phase1): "
      dir = gets.strip
      dir = "phase1" if dir.empty?
      
      print "Number of days for this phase: "
      days = gets.strip.to_i
      days = 500 if days <= 0
      
      @config['challenge']['phases']['1'] = {
        "name" => name,
        "dir" => dir,
        "days" => days
      }
      
      total_days = days
    else
      # Multiple phase setup
      puts "Enter details for each of your #{num_phases} phases:"
      
      (1..num_phases).each do |phase_num|
        puts "\nPhase #{phase_num}:"
        print "  Name: "
        name = gets.strip
        
        # Use a default name if empty
        if name.empty?
          if num_phases <= 5
            # Use some sensible defaults for common setups
            defaults = [
              "Fundamentals", 
              "Building Skills", 
              "Advanced Concepts", 
              "Projects", 
              "Mastery"
            ]
            name = defaults[phase_num - 1] || "Phase #{phase_num}"
          else
            name = "Phase #{phase_num}"
          end
        end
        
        print "  Directory name (phase#{phase_num}): "
        dir = gets.strip
        dir = "phase#{phase_num}" if dir.empty?
        
        print "  Number of days: "
        days = gets.strip.to_i
        days = 100 if days <= 0
        
        @config['challenge']['phases'][phase_num.to_s] = {
          "name" => name,
          "dir" => dir,
          "days" => days
        }
        
        total_days += days
      end
    end
    
    # Update total days
    @config['challenge']['total_days'] = total_days
    
    # Verify at least one phase exists
    if @config['challenge']['phases'].empty?
      @config['challenge']['phases'] = {
        "1" => { 
          "name" => "500 Day Coding Challenge", 
          "dir" => "phase1", 
          "days" => @config['challenge']['total_days'] 
        }
      }
    end
    
    # Display summary
    puts "\nChallenge Summary:"
    puts "- Total days: #{@config['challenge']['total_days']}"
    puts "- Days per week: #{@config['challenge']['days_per_week']}"
    puts "- Phases:"
    
    @config['challenge']['phases'].each do |num, phase|
      puts "  #{num}. #{phase['name']} (#{phase['days']} days)"
    end
  end

  # Update the existing installation
  def update
    puts "Updating 6/7 Coding Challenge v#{VERSION}"
    
    # Load existing config before updating
    load_existing_config
    
    # Interactive update if requested
    if @options[:interactive]
      puts "Would you like to update your configuration? (y/n): "
      update_config = gets.strip.downcase == 'y'
      
      if update_config
        gather_user_information
        gather_path_information
        gather_preferences
        gather_challenge_structure
      end
    end
    
    # Copy new/updated scripts
    install_scripts
    
    # Generate config module
    generate_config_module
    
    # Update configuration
    setup_configuration
    
    # Update .zshrc if needed
    update_zshrc
    
    puts "Update complete!"
  end

  # Generate complete config module
  def generate_config_module
    lib_target = File.join(@config['paths']['bin_dir'], 'lib')
    FileUtils.mkdir_p(lib_target)
    
    config_module_path = File.join(lib_target, 'cc_config.rb')
    
    # Create a complete new file from scratch rather than modifying an existing one
    cc_config_content = <<-RUBY
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
      system("which \#{command} > /dev/null 2>&1")
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
    "version" => "#{VERSION}",
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
    RUBY
    
    # Write the file
    File.write(config_module_path, cc_config_content)
    FileUtils.chmod(0755, config_module_path)
    
    puts "Generated configuration module at #{config_module_path}" if @options[:verbose]
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
    
    # Determine logs directory
    logs_dir = @config['paths']['log_dir']
    logs_path = File.join(logs_dir, 'logs')
    
    if Dir.exist?(logs_path)
      FileUtils.cp_r(logs_path, backup_dir)
      
      # Backup day counter
      if File.exist?(@day_counter)
        FileUtils.cp(@day_counter, File.join(backup_dir, '.cc-current-day'))
      end
      
      # Create backup info file
      backup_info = {
        "date" => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        "version" => VERSION,
        "current_day" => File.exist?(@day_counter) ? File.read(@day_counter).strip.to_i : 1,
        "config" => @config
      }
      
      File.write(File.join(backup_dir, 'backup-info.json'), JSON.pretty_generate(backup_info))
      
      puts "Logs backed up to #{backup_dir}"
    else
      puts "No logs directory found at #{logs_path}"
    end
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
      backup_info_path = File.join(dir, 'backup-info.json')
      if File.exist?(backup_info_path)
        begin
          backup_info = JSON.parse(File.read(backup_info_path))
          day = backup_info["current_day"] || "unknown"
          date = backup_info["date"] || File.basename(dir).sub("cc-logs-backup-", "")
          puts "#{index + 1}. #{File.basename(dir)} (Day #{day}, #{date})"
        rescue
          puts "#{index + 1}. #{File.basename(dir)}"
        end
      else
        puts "#{index + 1}. #{File.basename(dir)}"
      end
    end
    
    print "Select backup to restore (number): "
    selection = gets.strip.to_i
    
    if selection > 0 && selection <= backup_dirs.length
      selected_backup = backup_dirs[selection - 1]
      logs_backup = File.join(selected_backup, 'logs')
      
      if File.exist?(logs_backup)
        # Determine target logs directory
        logs_target = File.join(@config['paths']['log_dir'], 'logs')
        
        # Ensure target directory exists
        FileUtils.mkdir_p(File.dirname(logs_target))
        
        # Remove existing logs if they exist
        FileUtils.rm_rf(logs_target) if Dir.exist?(logs_target)
        
        # Copy backed up logs
        FileUtils.cp_r(logs_backup, logs_target)
        
        # Restore day counter
        backup_counter = File.join(selected_backup, '.cc-current-day')
        if File.exist?(backup_counter)
          print "Update day counter to match backup? (y/n): "
          update_counter = gets.strip.downcase == 'y'
          
          if update_counter
            FileUtils.cp(backup_counter, @day_counter)
          end
        end
        
        puts "Logs restored from #{File.basename(selected_backup)}"
      else
        puts "Invalid backup selected - no logs directory found."
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
    # Create project base directory
    FileUtils.mkdir_p(@config['paths']['base_dir'])
    
    # Create logs directory either in the main repo or separate dir
    log_dir = @config['paths']['log_dir']
    FileUtils.mkdir_p(log_dir)
    FileUtils.mkdir_p(File.join(log_dir, 'logs'))
    
    # Create phase directories
    @config['challenge']['phases'].each do |num, phase|
      phase_dir = File.join(@config['paths']['base_dir'], phase['dir'])
      FileUtils.mkdir_p(phase_dir)
    end
    
    # Create bin directory
    FileUtils.mkdir_p(@config['paths']['bin_dir'])
  end

  # Install challenge scripts
  def install_scripts
    # Find scripts in current directory
    script_files = Dir.glob(File.join(@scripts_dir, 'cc-*.rb'))
    
    # Copy and make executable
    script_files.each do |script|
      target_path = File.join(@config['paths']['bin_dir'], File.basename(script))
      FileUtils.cp(script, target_path)
      FileUtils.chmod(0755, target_path)
      puts "Installed: #{target_path}" if @options[:verbose]
    end
    
    # Create lib directory
    lib_source = File.join(@scripts_dir, 'lib')
    lib_target = File.join(@config['paths']['bin_dir'], 'lib')
    
    # Create lib directory if it doesn't exist
    FileUtils.mkdir_p(lib_target)
    
    puts "Created lib directory: #{lib_target}" if @options[:verbose]
  end

  # Set up configuration
  def setup_configuration
    # Create config file
    FileUtils.mkdir_p(File.dirname(@config_file))
    File.write(@config_file, JSON.pretty_generate(@config))
    puts "Configuration saved to #{@config_file}" if @options[:verbose]
  end

  # Set up git repository
  def setup_git_repository
    # Only set up if using GitHub
    return unless @config['user']['use_github']
    
    # Initialize main repository
    initialize_git_repo(@config['paths']['base_dir'], "main")
    
    # Handle log repository if it's different
    if @config['paths']['log_repo_type'] == "github" && !@config['paths']['log_repo'].empty?
      # Initialize local directory for the logs
      puts colorize("\nSetting up log repository...", :blue)
      
      # Ensure log directory exists
      log_dir = @config['paths']['log_dir']
      FileUtils.mkdir_p(log_dir)
      FileUtils.mkdir_p(File.join(log_dir, 'logs'))
      
      # Initialize git repo in log directory
      initialize_git_repo(log_dir, "logs", @config['paths']['log_repo'])
    elsif @config['paths']['log_repo_type'] == "local" && 
          @config['paths']['log_repo'] != "" && 
          @config['paths']['log_repo'] != @config['paths']['base_dir']
      # Local log directory, different from main repo
      puts colorize("\nSetting up local log repository...", :blue)
      initialize_git_repo(@config['paths']['log_repo'], "logs")
    end
  end

  # Initialize git repository at the given path
  def initialize_git_repo(repo_path, repo_type="main", github_repo_name=nil)
    # Ensure directory exists
    FileUtils.mkdir_p(repo_path)
    
    Dir.chdir(repo_path) do
      # Initialize git repo if not already initialized
      unless system("git rev-parse --is-inside-work-tree > /dev/null 2>&1")
        puts colorize("Initializing git repository in #{repo_path}...", :blue)
        system("git init")
        
        # Create basic .gitignore if it doesn't exist
        gitignore_path = File.join(repo_path, '.gitignore')
        unless File.exist?(gitignore_path)
          puts colorize("Creating .gitignore file for #{repo_type} repository...", :blue)
          basic_gitignore = <<~GITIGNORE
            # System Files
            .DS_Store
            .DS_Store?
            ._*
            .Spotlight-V100
            .Trashes
            ehthumbs.db
            Thumbs.db
            desktop.ini
            .directory
            *~
            .*.swp
            .*.swo
            
            # Editor directories and files
            .idea/
            .vscode/
            *.swp
            *.swo
            *~
            *.sublime-workspace
            
            # Obsidian configuration directories
            .obsidian/
            **/.obsidian/
            docs/.obsidian/
            */obsidian/
          GITIGNORE
          
          File.write(gitignore_path, basic_gitignore)
        end
        
        # Set up git config if username and email provided
        if @config['user']['github_username'] && !@config['user']['github_username'].empty?
          system("git config user.name \"#{@config['user']['name']}\"")
        end
        
        if @config['user']['github_email'] && !@config['user']['github_email'].empty?
          system("git config user.email \"#{@config['user']['github_email']}\"")
        end
        
        # Create a dummy file if directory is empty
        if Dir.empty?(repo_path) || (Dir.entries(repo_path) - %w[. .. .git .gitignore]).empty?
          FileUtils.mkdir_p(File.join(repo_path, 'logs'))
          File.write(File.join(repo_path, 'README.md'), "# #{repo_type == 'logs' ? 'Logs' : 'Coding Challenge'}\n\nRepository for #{repo_type == 'logs' ? 'logs' : 'code'} from the Coding Challenge.\n")
        end
        
        # Add and commit
        system("git add .")
        result = system("git commit -m 'Initial commit for Coding Challenge#{repo_type == 'logs' ? ' (Logs)' : ''}'")
        
        if result
          puts colorize("#{repo_type.capitalize} repository initialized successfully.", :green)
        else
          puts colorize("Warning: Could not create initial commit for #{repo_type} repository.", :yellow)
        end
        
        # Suggest GitHub remote setup
        if @config['user']['github_username'] && !@config['user']['github_username'].empty?
          username = @config['user']['github_username']
          
          # Use provided GitHub repo name or derive from directory
          if github_repo_name
            repo_name = github_repo_name
          else
            repo_name = File.basename(repo_path)
          end
          
          puts "\nTo connect to GitHub for the #{repo_type} repository, run:"
          puts "cd #{repo_path}"
          puts "git remote add origin https://github.com/#{username}/#{repo_name}.git"
          puts "git push -u origin main"
        end
      else
        puts colorize("Using existing git repository in #{repo_path}", :blue)
      end
    end
  end

  # Update .zshrc
  def update_zshrc
    # Aliases for challenge scripts
    aliases = [
      "# 6/7 Coding Challenge aliases",
      "alias ccstart='ruby #{@config['paths']['bin_dir']}/cc-start-day.rb'",
      "alias cclog='ruby #{@config['paths']['bin_dir']}/cc-log-progress.rb'",
      "alias ccpush='ruby #{@config['paths']['bin_dir']}/cc-push-updates.rb'",
      "alias ccstatus='ruby #{@config['paths']['bin_dir']}/cc-status.rb'",
      "alias ccconfig='ruby #{@config['paths']['bin_dir']}/cc-config.rb'",
      "alias ccupdate='ruby #{@config['paths']['bin_dir']}/cc-update.rb'",
      "alias ccbackup='ruby #{@config['paths']['bin_dir']}/cc-installer.rb --backup-logs'",
      "alias ccrestore='ruby #{@config['paths']['bin_dir']}/cc-installer.rb --restore-logs'",
      "alias ccuninstall='ruby #{@config['paths']['bin_dir']}/cc-uninstall.rb'"
    ]
    
    # Read current .zshrc if it exists
    if File.exist?(@zshrc_file)
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
    else
      # Create new .zshrc with just our aliases
      File.write(@zshrc_file, aliases.join("\n"))
    end
    
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
    Dir.glob(File.join(@config['paths']['bin_dir'], 'cc-*.rb')).each do |script|
      FileUtils.rm_f(script)
    end
    
    # Remove lib directory
    FileUtils.rm_rf(File.join(@config['paths']['bin_dir'], 'lib'))
  end

  # Remove configuration
  def remove_configuration
    FileUtils.rm_f(@config_file)
    FileUtils.rm_f(@day_counter)
  end

  # Remove .zshrc entries
  def remove_zshrc_entries
    if File.exist?(@zshrc_file)
      # Read .zshrc
      zshrc_content = File.read(@zshrc_file)
      
      # Remove challenge-related aliases
      zshrc_content = zshrc_content.gsub(/# 6\/7 Coding Challenge aliases[\s\S]*?(?=\n\n|\z)/, '')
      
      # Write back to .zshrc
      File.write(@zshrc_file, zshrc_content)
    end
  end

  # Colorize terminal output
  def colorize(text, color)
    return text unless @config['preferences']['display_colors']
    
    color_codes = {
      reset: "\e[0m",
      bold: "\e[1m",
      green: "\e[32m",
      yellow: "\e[33m",
      blue: "\e[34m",
      red: "\e[31m"
    }
    
    "#{color_codes[color] || ''}#{text}#{color_codes[:reset]}"
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