#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Installer Script
# A Ruby implementation of the setup script for 6/7 Coding Challenge
# Version 3.0.0 - Updated for configuration flexibility

require 'fileutils'
require 'optparse'
require 'json'

class CodingChallengeInstaller
  VERSION = '3.0.0'
  
  # Constants
  HOME_DIR = ENV['HOME']
  DEFAULT_BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
  DEFAULT_BIN_DIR = File.join(HOME_DIR, 'bin')
  CONFIG_FILE = File.join(HOME_DIR, '.cc-config.json')
  DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
  ZSHRC_FILE = File.join(HOME_DIR, '.zshrc')
  
  # ANSI color codes
  RESET = "\e[0m"
  BOLD = "\e[1m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN = "\e[36m"
  RED = "\e[31m"
  
  # Constructor
  def initialize
    @options = {
      action: :detect,
      force: false,
      verbose: false,
      interactive: true
    }
    
    @config = {
      "version" => VERSION,
      "user" => {
        "name" => ENV['USER'] || "User",
        "github_username" => "",
        "github_email" => ""
      },
      "paths" => {
        "base_dir" => DEFAULT_BASE_DIR,
        "bin_dir" => DEFAULT_BIN_DIR
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
    }

    # Determine script paths
    determine_script_paths
  end

  # Determine script paths based on where the installer is being run from
  def determine_script_paths
    # Check if we're running from within the repository
    @current_dir = File.dirname(File.expand_path(__FILE__))
    
    if File.exist?(File.join(@current_dir, '..', 'README.md')) || 
       File.exist?(File.join(@current_dir, 'README.md'))
      # We're likely in the repo, either in scripts/ or in the root
      if File.exist?(File.join(@current_dir, '..', 'README.md'))
        # We're in scripts/
        @repo_dir = File.expand_path(File.join(@current_dir, '..'))
      else
        # We're in the repo root
        @repo_dir = @current_dir
      end
      
      @scripts_dir = File.join(@repo_dir, 'scripts')
      @running_from_repo = true
      puts_info "Running from repository at #{@repo_dir}" if @options[:verbose]
    else
      # We're running the standalone installer
      @scripts_dir = @current_dir
      @running_from_repo = false
      puts_info "Running as standalone installer" if @options[:verbose]
    end
  end

  # Detect installed editor
  def detect_editor
    ['nvim', 'vim', 'code', 'emacs', 'nano'].each do |editor|
      return editor if command_exists?(editor)
    end
    ENV['EDITOR'] || 'vim'
  end

  # Colorize text
  def colorize(text, color_code)
    return text if ENV['NO_COLOR'] || !@config["preferences"]["display_colors"]
    "#{color_code}#{text}#{RESET}"
  end

  # Output formatting
  def puts_header(text)
    puts "\n#{colorize(text, BOLD)}"
    puts "=" * text.length
  end

  def puts_success(text)
    puts "#{colorize('✓', GREEN)} #{text}"
  end

  def puts_warning(text)
    puts "#{colorize('!', YELLOW)} #{text}"
  end

  def puts_error(text)
    puts "#{colorize('✗', RED)} #{text}"
  end

  def puts_info(text)
    puts "#{colorize('ℹ', BLUE)} #{text}"
  end

  # Parse command line options
  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
      
      opts.on('--install', 'Force fresh installation') do
        @options[:action] = :install
      end
      
      opts.on('--update', 'Update existing installation') do
        @options[:action] = :update
      end
      
      opts.on('--uninstall', 'Remove the installation') do
        @options[:action] = :uninstall
      end
      
      opts.on('--backup-logs', 'Backup log files') do
        @options[:action] = :backup_logs
      end
      
      opts.on('--restore-logs', 'Restore log files from backup') do
        @options[:action] = :restore_logs
      end
      
      opts.on('-f', '--force', 'Force operation without prompts') do
        @options[:force] = true
        @options[:interactive] = false
      end
      
      opts.on('-v', '--verbose', 'Verbose output') do
        @options[:verbose] = true
      end
      
      opts.on('-n', '--non-interactive', 'Non-interactive mode') do
        @options[:interactive] = false
      end
      
      opts.on('--version', 'Show version information') do
        puts "6/7 Coding Challenge Installer v#{VERSION}"
        exit
      end
      
      opts.on('-h', '--help', 'Show this help message') do
        puts opts
        exit
      end
    end.parse!
  end

  # Check if a command exists
  def command_exists?(command)
    system("which #{command} > /dev/null 2>&1")
  end

  # Check if scripts are installed
  def scripts_installed?
    bin_dir = @config["paths"]["bin_dir"]
    Dir.glob(File.join(bin_dir, "cc-*.rb")).any?
  end

  # Check if aliases are installed
  def aliases_installed?
    File.exist?(ZSHRC_FILE) && File.read(ZSHRC_FILE).include?('# 6/7 Coding Challenge aliases')
  end

  # Run the installer
  def run
    parse_options
    
    # Load existing config if available
    if File.exist?(CONFIG_FILE)
      begin
        saved_config = JSON.parse(File.read(CONFIG_FILE))
        deep_merge!(@config, saved_config)
      rescue JSON::ParserError
        puts_warning "Config file is malformed, using defaults"
      end
    end
    
    # If action is detect, check what's installed and prompt for action
    if @options[:action] == :detect
      @options[:action] = detect_installation
    end
    
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
      puts "Unknown action: #{@options[:action]}"
      exit 1
    end
  end

  # Detect what's already installed
  def detect_installation
    is_installed = false
    
    # Check for config file
    if File.exist?(CONFIG_FILE)
      is_installed = true
      puts_info "6/7 Coding Challenge is already installed (version #{@config['version']})."
    end
    
    # Check for scripts
    if scripts_installed?
      is_installed = true
      puts_info "Scripts are installed in #{@config['paths']['bin_dir']}."
    end
    
    # Check for aliases
    if aliases_installed?
      is_installed = true
      puts_info "Aliases are configured in ~/.zshrc."
    end
    
    # Check for day counter
    if File.exist?(DAY_COUNTER)
      is_installed = true
      current_day = File.read(DAY_COUNTER).strip rescue "unknown"
      puts_info "Day counter is set to #{current_day}."
    end
    
    # Check for project directory
    if Dir.exist?(@config["paths"]["base_dir"])
      is_installed = true
      puts_info "Project directory exists at #{@config['paths']['base_dir']}."
    end
    
    if is_installed
      puts "\nIt looks like 6/7 Coding Challenge is already installed."
      
      if @options[:force]
        return :update # Default to update if --force is specified
      elsif !@options[:interactive]
        return :update # Default to update in non-interactive mode
      end
      
      puts "What would you like to do?"
      puts ""
      puts "1) Update to the latest version"
      puts "2) Reinstall from scratch"
      puts "3) Backup challenge logs"
      puts "4) Restore challenge logs"
      puts "5) Uninstall completely"
      puts "6) Exit"
      puts ""
      
      print "Enter your choice (1-6): "
      choice = gets.strip.to_i
      
      case choice
      when 1
        puts_header "Updating 6/7 Coding Challenge"
        return :update
      when 2
        puts_header "Reinstalling 6/7 Coding Challenge"
        return :install
      when 3
        puts_header "Backing Up 6/7 Coding Challenge Logs"
        return :backup_logs
      when 4
        puts_header "Restoring 6/7 Coding Challenge Logs"
        return :restore_logs
      when 5
        puts_header "Uninstalling 6/7 Coding Challenge"
        return :uninstall
      else
        puts_info "Exiting..."
        exit 0
      end
    else
      return :install # Not installed, proceed with install
    end
  end

  # Deep merge two hashes
  def deep_merge!(original, overlay)
    overlay.each do |key, value|
      if value.is_a?(Hash) && original[key].is_a?(Hash)
        deep_merge!(original[key], value)
      else
        original[key] = value
      end
    end
  end

  # Check prerequisites
  def check_prerequisites
    puts_header "Checking Prerequisites"
    
    prereqs_ok = true
    
    # Check for zsh
    if ENV['SHELL'] !~ /zsh/
      puts_warning "Current shell is not zsh. Some features may not work correctly."
      prereqs_ok = false
    else
      puts_success "zsh is your current shell."
    end
    
    # Check for git
    if command_exists?('git')
      git_version = `git --version`.strip.split[2] rescue 'unknown'
      puts_success "git is installed (#{git_version})."
    else
      puts_error "git is not installed. Please install git first."
      prereqs_ok = false
    end
    
    # Check for tmux (optional but recommended)
    if command_exists?('tmux')
      tmux_version = `tmux -V`.strip.split[1] rescue 'unknown'
      puts_success "tmux is installed (#{tmux_version})."
    else
      puts_warning "tmux is not installed. It's recommended for the best experience."
      puts_info "For macOS: brew install tmux"
      puts_info "For Ubuntu/Debian: sudo apt install tmux"
      puts_info "For Fedora/RHEL: sudo dnf install tmux"
    end
    
    # Check for editor (nvim or vim)
    if command_exists?('nvim')
      puts_success "neovim is installed."
    elsif command_exists?('vim')
      puts_success "vim is installed."
    else
      puts_warning "Neither neovim nor vim is installed. A text editor is recommended."
    end
    
    # Check for Ruby
    if command_exists?('ruby')
      ruby_version = `ruby -v`.strip.split[1] rescue 'unknown'
      puts_success "Ruby is installed (#{ruby_version})."
    else
      puts_warning "Ruby is not installed. It will be needed for Phase 1."
    end
    
    # Check for bin directory
    bin_dir = @config['paths']['bin_dir']
    if Dir.exist?(bin_dir)
      puts_success "Scripts directory exists: #{bin_dir}"
    else
      puts_info "Scripts directory does not exist. It will be created: #{bin_dir}"
    end
    
    # Check if bin is in PATH
    if ENV['PATH'].split(':').include?(bin_dir)
      puts_success "Scripts directory is in your PATH."
    else
      puts_warning "Scripts directory is not in your PATH. We'll add it to your .zshrc"
    end
    
    prereqs_ok
  end

  # Create the directory structure
  def create_directories
    puts_header "Creating Directory Structure"
    
    base_dir = @config['paths']['base_dir']
    
    # Create base directory
    unless Dir.exist?(base_dir)
      FileUtils.mkdir_p(base_dir)
      puts_success "Created base directory: #{base_dir}"
    end
    
    # Create phase directories
    @config['challenge']['phases'].each do |phase_num, phase_info|
      phase_dir = File.join(base_dir, phase_info['dir'])
      unless Dir.exist?(phase_dir)
        FileUtils.mkdir_p(phase_dir)
        puts_success "Created phase directory: #{phase_dir}"
      end
    end
    
    # Create logs directory
    @config['challenge']['phases'].each do |phase_num, _|
      log_dir = File.join(base_dir, 'logs', "phase#{phase_num}")
      unless Dir.exist?(log_dir)
        FileUtils.mkdir_p(log_dir)
        puts_success "Created log directory: #{log_dir}"
      end
    end
    
    # Create week/day directories for phase 1
    days_per_phase = @config['challenge']['days_per_phase'].to_i
    days_per_week = @config['challenge']['days_per_week'].to_i
    weeks_per_phase = (days_per_phase.to_f / days_per_week).ceil
    
    phase1_dir = @config['challenge']['phases']['1']['dir']
    
    (1..weeks_per_phase).each do |week|
      week_formatted = format('%02d', week)
      week_dir = File.join(base_dir, phase1_dir, "week#{week_formatted}")
      
      unless Dir.exist?(week_dir)
        FileUtils.mkdir_p(week_dir)
        puts_success "Created week directory: #{week_dir}" if @options[:verbose]
      end
      
      # For week 1, create day directories to get started
      if week == 1
        (1..days_per_week).each do |day|
          day_dir = File.join(week_dir, "day#{day}")
          unless Dir.exist?(day_dir)
            FileUtils.mkdir_p(day_dir)
            puts_success "Created day directory: #{day_dir}" if @options[:verbose]
          end
        end
      end
    end
    
    puts_success "Directory structure created."
  end

  # Install the challenge
  def install
    puts_header "Installing 6/7 Coding Challenge"
    
    # Interactive configuration
    setup_interactive_config
    
    # Check prerequisites
    check_prerequisites
    
    # Create directories
    create_directories
    
    # Set up day counter
    setup_day_counter
    
    # Set up bin directory
    setup_bin_directory
    
    # Create script files
    create_script_files
    
    # Set up aliases
    setup_aliases
    
    # Setup git ignore
    setup_gitignore
    
    # Validate installation
    if validate_installation
      puts_success "Installation successfully validated!"
    else
      puts_warning "Installation validation failed. Please check the logs above for errors."
    end
    
    # Final message
    puts ""
    puts_success "Installation complete!"
    puts_info "To get started, run: source ~/.zshrc && ccstart"
  end

  # Validate the installation
  def validate_installation
    puts_header "Validating Installation"
    
    validation_ok = true
    bin_dir = @config['paths']['bin_dir']
    
    # Check for required scripts
    required_scripts = ["cc-start-day.rb", "cc-log-progress.rb", "cc-push-updates.rb", 
                        "cc-status.rb", "cc-config.rb", "cc-update.rb", "cc-uninstall.rb"]
    
    required_scripts.each do |script|
      script_path = File.join(bin_dir, script)
      if File.exist?(script_path) && File.executable?(script_path)
        puts_success "Validated script: #{script}"
      else
        puts_error "Missing or non-executable script: #{script_path}"
        validation_ok = false
      end
    end
    
    # Check for lib directory and config module
    lib_dir = File.join(bin_dir, 'lib')
    config_module = File.join(lib_dir, 'cc_config.rb')
    
    if Dir.exist?(lib_dir)
      puts_success "Validated lib directory: #{lib_dir}"
    else
      puts_error "Missing lib directory: #{lib_dir}"
      validation_ok = false
    end
    
    if File.exist?(config_module)
      puts_success "Validated config module: #{config_module}"
    else
      puts_error "Missing config module: #{config_module}"
      validation_ok = false
    end
    
    # Check for config file
    if File.exist?(CONFIG_FILE)
      begin
        config = JSON.parse(File.read(CONFIG_FILE))
        puts_success "Validated config file: #{CONFIG_FILE}"
      rescue JSON::ParserError
        puts_error "Invalid JSON in config file: #{CONFIG_FILE}"
        validation_ok = false
      end
    else
      puts_error "Missing config file: #{CONFIG_FILE}"
      validation_ok = false
    end
    
    # Check for day counter
    if File.exist?(DAY_COUNTER)
      puts_success "Validated day counter: #{DAY_COUNTER}"
    else
      puts_error "Missing day counter: #{DAY_COUNTER}"
      validation_ok = false
    end
    
    # Check for aliases in .zshrc
    if aliases_installed?
      puts_success "Validated aliases in .zshrc"
    else
      puts_error "Missing aliases in .zshrc"
      validation_ok = false
    end
    
    validation_ok
  end

  # Set up or preserve the day counter
  def setup_day_counter
    if File.exist?(DAY_COUNTER)
      # Keep existing counter
      current_day = File.read(DAY_COUNTER).strip rescue "1"
      puts_info "Using existing day counter: #{current_day}"
    else
      # Create new counter
      File.write(DAY_COUNTER, "1")
      puts_success "Created day counter: 1"
    end
  end

  # Set up the bin directory
  def setup_bin_directory
    bin_dir = @config['paths']['bin_dir']
    
    unless Dir.exist?(bin_dir)
      FileUtils.mkdir_p(bin_dir)
      puts_success "Created bin directory: #{bin_dir}"
    end
    
    # Create lib directory
    lib_dir = File.join(bin_dir, 'lib')
    unless Dir.exist?(lib_dir)
      FileUtils.mkdir_p(lib_dir)
      puts_success "Created lib directory: #{lib_dir}"
    end
    
    # Add to PATH if needed
    unless ENV['PATH'].split(':').include?(bin_dir)
      File.open(ZSHRC_FILE, 'a') do |f|
        f.puts "\n# Add bin directory to PATH"
        f.puts 'export PATH="$HOME/bin:$PATH"'
      end
      puts_success "Added bin directory to PATH in .zshrc"
    end
  end

  # Create script files by copying from repository
  def create_script_files
    puts_header "Creating Script Files"
    
    bin_dir = @config['paths']['bin_dir']
    lib_dir = File.join(bin_dir, 'lib')
    
    # Create configuration module from template
    cc_config_template = <<~'RUBY'
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
RUBY

    config_module_path = File.join(lib_dir, 'cc_config.rb')
    File.write(config_module_path, cc_config_template)
    FileUtils.chmod(0755, config_module_path)
    puts_success "Created configuration module: #{config_module_path}"
    
    # List of scripts to copy from repo or create
    scripts = [
      'cc-start-day.rb',
      'cc-log-progress.rb',
      'cc-push-updates.rb',
      'cc-status.rb',
      'cc-config.rb',
      'cc-update.rb',
      'cc-uninstall.rb'
    ]
    
    scripts.each do |script_name|
      target_path = File.join(bin_dir, script_name)
      
      # Try to find script in repository
      source_path = nil
      
      if @running_from_repo
        # Check in scripts directory
        potential_path = File.join(@scripts_dir, script_name)
        if File.exist?(potential_path)
          source_path = potential_path
        end
      end
      
      if source_path
        # Copy from repository
        FileUtils.cp(source_path, target_path)
        puts_success "Copied script from repository: #{script_name}"
      else
        # Create a basic placeholder script
        basic_script_content = <<~RUBY
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          
          # 6/7 Coding Challenge - #{script_name.sub('.rb', '').split('-').map(&:capitalize).join(' ')} Script
          # This is a placeholder generated by the installer
          
          require_relative 'lib/cc_config'
          
          puts "#{script_name} placeholder - Please implement this script or copy from repository"
          puts "You can run 'ccupdate' after adding the script to update all scripts"
        RUBY
        
        File.write(target_path, basic_script_content)
        puts_warning "Created placeholder script: #{script_name} (needs implementation)"
      end
      
      # Make script executable
      FileUtils.chmod(0755, target_path)
    end
    
    # Create a config script
    config_script_content = <<~RUBY
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      
      # 6/7 Coding Challenge - Config Script
      # Views and modifies configuration settings
      
      require 'json'
      require_relative 'lib/cc_config'
      
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
            puts "Error: Invalid format for --set. Use KEY=VALUE."
            exit 1
          end
        end
      end.parse!
      
      # Reset configuration if requested
      if options[:reset]
        config = CCConfig::DEFAULT_CONFIG.dup
        CCConfig.save(config)
        puts "Configuration has been reset to defaults."
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
          if value =~ /^\\d+$/
            value = value.to_i
          elsif value =~ /^\\d+\\.\\d+$/
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
        puts_success "Configuration script created successfully"
        options[:view] = true
      end
      
      # Interactive configuration
      if options[:interactive]
        puts "Interactive Configuration"
        puts "======================="
        
        config = CCConfig.load
        
        # User info
        puts "\\nUser Information:"
        print "Your name (#{@config['user']['name']}): "
        name = gets.strip
        @config['user']['name'] = name unless name.empty?
        
        print "GitHub username (#{@config['user']['github_username']}): "
        github_username = gets.strip
        @config['user']['github_username'] = github_username unless github_username.empty?
        
        print "GitHub email (#{@config['user']['github_email']}): "
        github_email = gets.strip
        @config['user']['github_email'] = github_email unless github_email.empty?
        
        # Paths
        puts "\\nDirectories:"
        print "Base directory (#{@config['paths']['base_dir']}): "
        base_dir = gets.strip
        @config['paths']['base_dir'] = base_dir unless base_dir.empty?
        
        print "Scripts directory (#{@config['paths']['bin_dir']}): "
        bin_dir = gets.strip
        @config['paths']['bin_dir'] = bin_dir unless bin_dir.empty?
        
        # Preferences
        puts "\\nPreferences:"
        print "Preferred editor (#{@config['preferences']['editor']}): "
        editor = gets.strip
        @config['preferences']['editor'] = editor unless editor.empty?
        
        print "Use tmux? (#{@config['preferences']['use_tmux'] ? 'yes' : 'no'}): "
        use_tmux = gets.strip.downcase
        if use_tmux == 'yes' || use_tmux == 'y'
          @config['preferences']['use_tmux'] = true
        elsif use_tmux == 'no' || use_tmux == 'n'
          @config['preferences']['use_tmux'] = false
        end
        
        print "Auto push to GitHub? (#{@config['preferences']['auto_push'] ? 'yes' : 'no'}): "
        auto_push = gets.strip.downcase
        if auto_push == 'yes' || auto_push == 'y'
          @config['preferences']['auto_push'] = true
        elsif auto_push == 'no' || auto_push == 'n'
          @config['preferences']['auto_push'] = false
        end
        
        # Challenge structure
        puts "\\nChallenge Structure:"
        print "Do you want to customize the challenge structure? (y/n): "
        customize_structure = gets.strip.downcase == 'y'
        
        if customize_structure
          print "Days per week (#{@config['challenge']['days_per_week']}): "
          days_per_week = gets.strip
          @config['challenge']['days_per_week'] = days_per_week.to_i unless days_per_week.empty?
          
          print "Days per phase (#{@config['challenge']['days_per_phase']}): "
          days_per_phase = gets.strip
          @config['challenge']['days_per_phase'] = days_per_phase.to_i unless days_per_phase.empty?
          
          print "Total days (#{@config['challenge']['total_days']}): "
          total_days = gets.strip
          @config['challenge']['total_days'] = total_days.to_i unless total_days.empty?
          
          # Phase configuration
          puts "\\nPhase Names and Directories:"
          @config['challenge']['phases'].each do |phase_num, phase_info|
            puts "Phase #{phase_num}:"
            print "  Name (#{phase_info['name']}): "
            name = gets.strip
            @config['challenge']['phases'][phase_num]['name'] = name unless name.empty?
            
            print "  Directory (#{phase_info['dir']}): "
            dir = gets.strip
            @config['challenge']['phases'][phase_num]['dir'] = dir unless dir.empty?
          end
        end
        
        # Save updated config
        CCConfig.save(config)
        puts "Configuration saved successfully."
        options[:view] = true
      end
      
      # View configuration
      if options[:view]
        config = CCConfig.load
        puts JSON.pretty_generate(config)
      end
    RUBY
    
    config_script_path = File.join(bin_dir, 'cc-config.rb')
    File.write(config_script_path, config_script_content)
    FileUtils.chmod(0755, config_script_path)
    puts_success "Created config script: #{config_script_path}"
  end

  # Interactive configuration setup
  def setup_interactive_config
    return if @options[:force] || !@options[:interactive]
    
    puts_header "Configuration Setup"
    
    # User info
    puts "Please provide some information to customize your installation:"
    print "Your name (#{@config['user']['name']}): "
    name = gets.strip
    @config['user']['name'] = name unless name.empty?
    
    print "GitHub username (#{@config['user']['github_username']}): "
    github_username = gets.strip
    @config['user']['github_username'] = github_username unless github_username.empty?
    
    print "GitHub email (#{@config['user']['github_email']}): "
    github_email = gets.strip
    @config['user']['github_email'] = github_email unless github_email.empty?
    
    # Paths
    puts "\nSetup project location:"
    default_base_dir = @config['paths']['base_dir']
    print "Base directory (#{default_base_dir}): "
    base_dir = gets.strip
    @config['paths']['base_dir'] = base_dir unless base_dir.empty?
    
    default_bin_dir = @config['paths']['bin_dir']
    print "Scripts directory (#{default_bin_dir}): "
    bin_dir = gets.strip
    @config['paths']['bin_dir'] = bin_dir unless bin_dir.empty?
    
    # Preferences
    puts "\nPreferences:"
    
    # Detect editors
    detected_editors = []
    ['nvim', 'vim', 'emacs', 'nano', 'code'].each do |editor|
      detected_editors << editor if command_exists?(editor)
    end
    
    if detected_editors.any?
      puts "Detected editors: #{detected_editors.join(', ')}"
    end
    
    print "Preferred editor (#{@config['preferences']['editor']}): "
    editor = gets.strip
    @config['preferences']['editor'] = editor unless editor.empty?
    
    print "Use tmux? (#{@config['preferences']['use_tmux'] ? 'yes' : 'no'}): "
    use_tmux = gets.strip.downcase
    if use_tmux == 'yes' || use_tmux == 'y'
      @config['preferences']['use_tmux'] = true
    elsif use_tmux == 'no' || use_tmux == 'n'
      @config['preferences']['use_tmux'] = false
    end
    
    print "Auto push to GitHub? (#{@config['preferences']['auto_push'] ? 'yes' : 'no'}): "
    auto_push = gets.strip.downcase
    if auto_push == 'yes' || auto_push == 'y'
      @config['preferences']['auto_push'] = true
    elsif auto_push == 'no' || auto_push == 'n'
      @config['preferences']['auto_push'] = false
    end
    
    # Challenge Structure
    puts "\nChallenge Structure:"
    puts "Note: Changing these values may affect your progress tracking."
    print "Do you want to customize the challenge structure? (y/n): "
    customize_structure = gets.strip.downcase == 'y'
    
    if customize_structure
      print "Days per week (#{@config['challenge']['days_per_week']}): "
      days_per_week = gets.strip
      @config['challenge']['days_per_week'] = days_per_week.to_i unless days_per_week.empty?
      
      print "Days per phase (#{@config['challenge']['days_per_phase']}): "
      days_per_phase = gets.strip
      @config['challenge']['days_per_phase'] = days_per_phase.to_i unless days_per_phase.empty?
      
      print "Total days (#{@config['challenge']['total_days']}): "
      total_days = gets.strip
      @config['challenge']['total_days'] = total_days.to_i unless total_days.empty?
      
      # Phase configuration
      puts "\nPhase Names and Directories:"
      @config['challenge']['phases'].each do |phase_num, phase_info|
        puts "Phase #{phase_num}:"
        print "  Name (#{phase_info['name']}): "
        name = gets.strip
        @config['challenge']['phases'][phase_num]['name'] = name unless name.empty?
        
        print "  Directory (#{phase_info['dir']}): "
        dir = gets.strip
        @config['challenge']['phases'][phase_num]['dir'] = dir unless dir.empty?
      end
    end
    
    # Save updated config
    save_config
    puts_success "Configuration saved"
  end

  # Save configuration
  def save_config
    FileUtils.mkdir_p(File.dirname(CONFIG_FILE))
    File.write(CONFIG_FILE, JSON.pretty_generate(@config))
  end

  # Update the challenge
  def update
    puts_header "Updating 6/7 Coding Challenge"
    
    # Backup existing scripts
    backup_scripts
    
    # Interactive configuration
    setup_interactive_config
    
    # Update directories
    create_directories
    
    # Ensure bin directory
    setup_bin_directory
    
    # Update script files
    create_script_files
    
    # Ensure aliases
    setup_aliases
    
    # Validate installation
    if validate_installation
      puts_success "Update successfully validated!"
    else
      puts_warning "Update validation failed. Please check the logs above for errors."
    end
    
    # Final message
    puts ""
    puts_success "Update complete!"
    puts_info "Your current progress and day counter have been preserved."
    puts_info "To continue, run: source ~/.zshrc && ccstatus"
  end

  # Backup existing scripts
  def backup_scripts
    if scripts_installed?
      puts_info "Backing up existing scripts..."
      bin_dir = @config['paths']['bin_dir']
      backup_dir = File.join(bin_dir, "cc-backup-#{Time.now.strftime('%Y%m%d%H%M%S')}")
      FileUtils.mkdir_p(backup_dir)
      
      Dir.glob(File.join(bin_dir, "cc-*.rb")).each do |script|
        FileUtils.cp(script, backup_dir)
      end
      
      # Back up lib directory if it exists
      lib_dir = File.join(bin_dir, 'lib')
      if Dir.exist?(lib_dir)
        FileUtils.cp_r(lib_dir, backup_dir)
      end
      
      puts_success "Existing scripts backed up to #{backup_dir}."
    end
  end

  # Uninstall the challenge
  def uninstall
    puts_header "Uninstalling 6/7 Coding Challenge"
    
    # Remove scripts
    remove_scripts
    
    # Remove aliases
    remove_aliases
    
    # Prompt about day counter
    if File.exist?(DAY_COUNTER) && !@options[:force]
      print "Do you want to remove the day counter? This will reset your progress. (y/n): "
      remove_counter = gets.strip.downcase == 'y'
    else
      remove_counter = @options[:force]
    end
    
    if remove_counter
      if File.exist?(DAY_COUNTER)
        File.delete(DAY_COUNTER)
        puts_success "Day counter removed."
      end
    else
      puts_info "Day counter preserved. Your progress is safe."
    end
    
    # Prompt about project directory
    base_dir = @config['paths']['base_dir']
    if Dir.exist?(base_dir) && !@options[:force]
      print "Do you want to remove the project directory? This will delete all your code and logs. (y/n): "
      remove_dir = gets.strip.downcase == 'y'
    else
      remove_dir = false # Never force remove the project directory
    end
    
    if remove_dir
      FileUtils.rm_rf(base_dir)
      puts_success "Project directory removed."
    else
      puts_info "Project directory preserved. Your code and logs are safe."
    end
    
    # Remove config file
    if File.exist?(CONFIG_FILE)
      File.delete(CONFIG_FILE)
      puts_success "Configuration file removed."
    end
    
    # Final message
    puts ""
    puts_success "Uninstallation complete!"
    puts_info "Don't forget to source your .zshrc to apply changes: source ~/.zshrc"
  end

  # Remove script files
  def remove_scripts
    puts_info "Removing script files..."
    bin_dir = @config['paths']['bin_dir']
    
    Dir.glob(File.join(bin_dir, "cc-*.rb")).each do |script|
      File.delete(script)
      puts_success "Removed script: #{script}" if @options[:verbose]
    end
    
    # Also remove lib directory if it exists
    lib_dir = File.join(bin_dir, "lib")
    if Dir.exist?(lib_dir)
      FileUtils.rm_rf(lib_dir)
      puts_success "Removed lib directory: #{lib_dir}"
    end
    
    puts_success "All scripts removed."
  end

  # Backup logs functionality
  def backup_logs
    puts_header "Backing Up Log Files"
    
    base_dir = @config['paths']['base_dir']
    logs_dir = File.join(base_dir, 'logs')
    
    unless Dir.exist?(logs_dir)
      puts_warning "No logs directory found at #{logs_dir}"
      puts_info "Nothing to backup."
      return
    end
    
    # Prompt for backup location
    puts "Where would you like to backup your logs?"
    puts "1) Local backup (in your home directory)"
    puts "2) To the git repository"
    puts "3) Custom location"
    
    print "Enter your choice (1-3): "
    choice = gets.strip.to_i
    
    case choice
    when 1
      # Local backup in home directory
      backup_dir = File.join(HOME_DIR, 'cc-logs-backup')
      backup_logs_to_directory(logs_dir, backup_dir)
    when 2
      # Backup to git repository
      if Dir.exist?(File.join(base_dir, '.git'))
        # Create a special branch for logs
        Dir.chdir(base_dir) do
          current_branch = `git rev-parse --abbrev-ref HEAD`.strip
          timestamp = Time.now.strftime('%Y%m%d%H%M%S')
          branch_name = "logs-backup-#{timestamp}"
          
          puts_info "Creating a new git branch: #{branch_name}"
          
          # Create and switch to the new branch
          if system("git checkout -b #{branch_name}")
            # Add all logs
            system("git add #{logs_dir}/*")
            
            # Commit the changes
            if system("git commit -m \"Backup logs - #{timestamp}\"")
              puts_success "Logs backed up to git branch: #{branch_name}"
              
              # Push to remote if remote exists and user wants to
              remote_exists = system("git remote -v | grep origin > /dev/null 2>&1")
              
              if remote_exists
                print "Do you want to push this branch to remote? (y/n): "
                push_remote = gets.strip.downcase == 'y'
                
                if push_remote
                  if system("git push -u origin #{branch_name}")
                    puts_success "Pushed logs backup to remote."
                  else
                    puts_error "Failed to push to remote."
                  end
                end
              end
              
              # Switch back to original branch
              system("git checkout #{current_branch}")
            else
              puts_error "Failed to commit logs. Switching back to original branch."
              system("git checkout #{current_branch}")
            end
          else
            puts_error "Failed to create git branch for backup."
          end
        end
      else
        puts_error "No git repository found at #{base_dir}"
        puts_info "Defaulting to local backup."
        backup_dir = File.join(HOME_DIR, 'cc-logs-backup')
        backup_logs_to_directory(logs_dir, backup_dir)
      end
    when 3
      # Custom location
      print "Enter full path for backup: "
      custom_dir = gets.strip
      
      # Expand ~ to home directory if needed
      custom_dir = custom_dir.gsub(/^~/, HOME_DIR)
      
      backup_logs_to_directory(logs_dir, custom_dir)
    else
      puts_error "Invalid choice. Defaulting to local backup."
      backup_dir = File.join(HOME_DIR, 'cc-logs-backup')
      backup_logs_to_directory(logs_dir, backup_dir)
    end
  end

  def backup_logs_to_directory(logs_dir, backup_dir)
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    backup_path = "#{backup_dir}-#{timestamp}"
    
    # Create backup directory
    FileUtils.mkdir_p(backup_path)
    
    # Copy all logs
    FileUtils.cp_r(Dir.glob("#{logs_dir}/*"), backup_path)
    
    # Create metadata file with information about the backup
    current_day = File.exist?(DAY_COUNTER) ? File.read(DAY_COUNTER).strip : "unknown"
    
    File.open(File.join(backup_path, "backup-info.json"), 'w') do |f|
      f.puts JSON.pretty_generate({
        'timestamp' => timestamp,
        'current_day' => current_day,
        'base_dir' => @config['paths']['base_dir'],
        'phases' => @config['challenge']['phases'],
        'days_per_week' => @config['challenge']['days_per_week'],
        'days_per_phase' => @config['challenge']['days_per_phase'],
        'total_days' => @config['challenge']['total_days']
      })
    end
    
    puts_success "Logs backed up to: #{backup_path}"
    
    # Create simple restore script
    restore_script = File.join(backup_path, "restore.rb")
    File.open(restore_script, 'w') do |f|
      f.puts "#!/usr/bin/env ruby"
      f.puts "# 6/7 Coding Challenge - Logs Restore Script"
      f.puts "# Created: #{timestamp}"
      f.puts ""
      f.puts "require 'fileutils'"
      f.puts ""
      f.puts "BACKUP_DIR = File.dirname(__FILE__)"
      f.puts "TARGET_DIR = ARGV[0] || '#{@config['paths']['base_dir']}/logs'"
      f.puts ""
      f.puts "puts \"Restoring logs from #{backup_path} to \#{TARGET_DIR}\""
      f.puts "print \"Continue? (y/n): \""
      f.puts "confirm = gets.strip.downcase"
      f.puts "exit unless confirm == 'y'"
      f.puts ""
      f.puts "# Create target directory if it doesn't exist"
      f.puts "FileUtils.mkdir_p(TARGET_DIR)"
      f.puts ""
      f.puts "# Copy all files except this script and the info file"
      f.puts "Dir.glob(File.join(BACKUP_DIR, '*')).each do |file|"
      f.puts "  next if file == __FILE__ || file.end_with?('backup-info.json')"
      f.puts "  FileUtils.cp_r(file, TARGET_DIR)"
      f.puts "  puts \"Copied \#{File.basename(file)}\""
      f.puts "end"
      f.puts ""
      f.puts "puts \"Logs restored successfully!\""
    end
    
    FileUtils.chmod(0755, restore_script)
    
    puts_info "To restore these logs later, run: ruby #{restore_script}"
  end

  def restore_logs
    puts_header "Restoring Log Files"
    
    # Prompt for restore source
    puts "Where would you like to restore logs from?"
    puts "1) Local backup"
    puts "2) From git repository"
    puts "3) Custom location"
    
    print "Enter your choice (1-3): "
    choice = gets.strip.to_i
    
    base_dir = @config['paths']['base_dir']
    logs_dir = File.join(base_dir, 'logs')
    
    case choice
    when 1
      # List local backups in home directory
      backup_pattern = File.join(HOME_DIR, 'cc-logs-backup-*')
      backups = Dir.glob(backup_pattern).sort.reverse
      
      if backups.empty?
        puts_warning "No local backups found matching #{backup_pattern}"
        return
      end
      
      puts "Available backups:"
      backups.each_with_index do |backup, index|
        # Try to get metadata from backup-info.json
        info_file = File.join(backup, 'backup-info.json')
        if File.exist?(info_file)
          begin
            info = JSON.parse(File.read(info_file))
            puts "#{index + 1}) #{File.basename(backup)} - Day #{info['current_day']}"
          rescue
            puts "#{index + 1}) #{File.basename(backup)}"
          end
        else
          puts "#{index + 1}) #{File.basename(backup)}"
        end
      end
      
      print "Select backup to restore (1-#{backups.length}): "
      backup_index = gets.strip.to_i - 1
      
      if backup_index >= 0 && backup_index < backups.length
        selected_backup = backups[backup_index]
        restore_logs_from_directory(selected_backup, logs_dir)
      else
        puts_error "Invalid selection."
      end
    when 2
      # Restore from git repository
      if Dir.exist?(File.join(base_dir, '.git'))
        Dir.chdir(base_dir) do
          current_branch = `git rev-parse --abbrev-ref HEAD`.strip
          
          # List backup branches
          backup_branches = `git branch -a | grep logs-backup`.split("\n").map(&:strip)
          
          if backup_branches.empty?
            puts_warning "No backup branches found in git repository."
            return
          end
          
          puts "Available backup branches:"
          backup_branches.each_with_index do |branch, index|
            # Clean branch name (remove * and leading/trailing spaces)
            branch_name = branch.gsub(/^\*?\s*/, '').strip
            puts "#{index + 1}) #{branch_name}"
          end
          
          print "Select branch to restore from (1-#{backup_branches.length}): "
          branch_index = gets.strip.to_i - 1
          
          if branch_index >= 0 && branch_index < backup_branches.length
            branch_name = backup_branches[branch_index].gsub(/^\*?\s*/, '').strip
            
            if branch_name.start_with?('remotes/')
              # For remote branches, create a local tracking branch
              local_branch = branch_name.split('/', 3)[2]
              system("git checkout -b #{local_branch} #{branch_name}")
              branch_name = local_branch
            end
            
            # Check out the selected branch
            if system("git checkout #{branch_name}")
              puts_success "Switched to branch: #{branch_name}"
              
              # Copy logs from branch to the logs directory
              FileUtils.mkdir_p(logs_dir)
              FileUtils.cp_r(Dir.glob("#{logs_dir}/*"), File.dirname(logs_dir))
              
              # Switch back to original branch
              system("git checkout #{current_branch}")
              
              puts_success "Logs restored from branch: #{branch_name}"
            else
              puts_error "Failed to switch to branch #{branch_name}"
            end
          else
            puts_error "Invalid selection."
          end
        end
      else
        puts_error "No git repository found at #{base_dir}"
      end
    when 3
      # Custom location
      print "Enter full path to backup directory: "
      custom_dir = gets.strip
      
      # Expand ~ to home directory if needed
      custom_dir = custom_dir.gsub(/^~/, HOME_DIR)
      
      if Dir.exist?(custom_dir)
        restore_logs_from_directory(custom_dir, logs_dir)
      else
        puts_error "Directory not found: #{custom_dir}"
      end
    else
      puts_error "Invalid choice."
    end
  end

  def restore_logs_from_directory(source_dir, target_dir)
    unless Dir.exist?(source_dir)
      puts_error "Source directory does not exist: #{source_dir}"
      return
    end
    
    puts_info "Restoring logs from #{source_dir} to #{target_dir}"
    print "This will overwrite existing logs. Continue? (y/n): "
    confirm = gets.strip.downcase
    
    unless confirm == 'y'
      puts_info "Restore cancelled."
      return
    end
    
    # Create target directory if it doesn't exist
    FileUtils.mkdir_p(target_dir)
    
    # Copy all files except the restore script and the info file
    Dir.glob(File.join(source_dir, '*')).each do |file|
      next if file.end_with?('restore.rb') || file.end_with?('backup-info.json')
      FileUtils.cp_r(file, target_dir)
    end
    
    puts_success "Logs restored successfully!"
    
    # Check for day counter in backup info
    info_file = File.join(source_dir, 'backup-info.json')
    if File.exist?(info_file)
      begin
        info = JSON.parse(File.read(info_file))
        backup_day = info['current_day']
        
        if backup_day && backup_day != "unknown"
          print "Update day counter to match backup (#{backup_day})? (y/n): "
          update_counter = gets.strip.downcase == 'y'
          
          if update_counter
            File.write(DAY_COUNTER, backup_day.to_s)
            puts_success "Day counter updated to: #{backup_day}"
          end
        end
      rescue
        puts_warning "Could not read backup metadata."
      end
    end
  end

  # Set up aliases in .zshrc
  def setup_aliases
    zshrc_file = ZSHRC_FILE
    bin_dir = @config['paths']['bin_dir']
    
    # Aliases block with backup/restore commands
    aliases_marker = '# 6/7 Coding Challenge aliases'
    aliases_block = <<~ALIASES
      #{aliases_marker}
      alias ccstart="#{bin_dir}/cc-start-day.rb"
      alias cclog="#{bin_dir}/cc-log-progress.rb"
      alias ccpush="#{bin_dir}/cc-push-updates.rb"
      alias ccstatus="#{bin_dir}/cc-status.rb"
      alias ccconfig="#{bin_dir}/cc-config.rb"
      alias ccupdate="#{bin_dir}/cc-update.rb"
      alias ccbackup="#{bin_dir}/cc-installer.rb --backup-logs"
      alias ccrestore="#{bin_dir}/cc-installer.rb --restore-logs"
      alias ccuninstall="#{bin_dir}/cc-uninstall.rb"
    ALIASES
    
    if aliases_installed?
      # Replace existing aliases
      content = File.read(zshrc_file)
      marker_index = content.index(aliases_marker)
      
      if marker_index
        # Find the end of the aliases block
        next_line_index = content.index("\n", marker_index + aliases_marker.length)
        while next_line_index && content[next_line_index + 1] =~ /^alias cc/
          next_line_index = content.index("\n", next_line_index + 1)
        end
        
        # Replace the block
        if next_line_index
          new_content = content[0...marker_index] + aliases_block + content[next_line_index..-1]
          File.write(zshrc_file, new_content)
          puts_success "Updated aliases in .zshrc"
        end
      end
    else
      # Add new aliases
      File.open(zshrc_file, 'a') do |f|
        f.puts "\n#{aliases_block}"
      end
      puts_success "Added aliases to .zshrc"
    end
  end

  # Remove aliases from .zshrc
  def remove_aliases
    zshrc_file = ZSHRC_FILE
    if aliases_installed?
      puts_info "Removing aliases from .zshrc..."
      content = File.read(zshrc_file)
      aliases_marker = '# 6/7 Coding Challenge aliases'
      marker_index = content.index(aliases_marker)
      
      if marker_index
        # Find the end of the aliases block
        next_line_index = content.index("\n", marker_index + aliases_marker.length)
        while next_line_index && content[next_line_index + 1] =~ /^alias cc/
          next_line_index = content.index("\n", next_line_index + 1)
        end
        
        # Remove the block
        if next_line_index
          new_content = content[0...marker_index] + content[next_line_index..-1]
          File.write(zshrc_file, new_content)
          puts_success "Removed aliases from .zshrc"
        end
      end
    end
  end

  # Setup .gitignore file
  def setup_gitignore
    base_dir = @config['paths']['base_dir']
    gitignore_path = File.join(base_dir, '.gitignore')
    
    gitignore_content = <<~GITIGNORE
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
      
      # Linux
      .directory
      *~

      # Windows
      Thumbs.db
      ehthumbs.db
      desktop.ini

      # macOS
      .DS_Store
      .DS_Store?
      ._*
      .Spotlight-V100
      .Trashes

      # Vim
      .*.swp
      .*.swo
      
      # Obsidian configuration directories
      .obsidian/
      **/.obsidian/
      docs/.obsidian/
      */obsidian/
      
      # Editor directories and files
      .idea/
      .vscode/
      *.swp
      *.swo
      *~
      *.sublime-workspace
    GITIGNORE
    
    if File.exist?(gitignore_path)
      puts_info "Using existing .gitignore file."
    else
      File.write(gitignore_path, gitignore_content)
      puts_success "Created .gitignore file."
    end
  end
end

# Run the installer if this script is executed directly
if __FILE__ == $PROGRAM_NAME
  CodingChallengeInstaller.new.run
end