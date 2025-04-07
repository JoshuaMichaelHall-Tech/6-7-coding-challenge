#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Installer Script
# A Ruby implementation of the setup script for 6/7 Coding Challenge
# Author: Joshua Michael Hall

require 'fileutils'
require 'optparse'
require 'json'

class CodingChallengeInstaller
  VERSION = '2.0.1'
  
  # Paths
  HOME_DIR = ENV['HOME']
  BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
  BIN_DIR = File.join(HOME_DIR, 'bin')
  CONFIG_FILE = File.join(HOME_DIR, '.cc-config')
  DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
  ZSHRC_FILE = File.join(HOME_DIR, '.zshrc')

  # Aliases block
  ALIASES_MARKER = '# 6/7 Coding Challenge aliases'
  ALIASES_BLOCK = <<~ALIASES
    #{ALIASES_MARKER}
    alias ccstart="#{BIN_DIR}/cc-start-day.rb"
    alias cclog="#{BIN_DIR}/cc-log-progress.rb"
    alias ccpush="#{BIN_DIR}/cc-push-updates.rb"
    alias ccstatus="#{BIN_DIR}/cc-status.rb"
    alias ccupdate="#{BIN_DIR}/cc-update.rb"
    alias ccuninstall="#{BIN_DIR}/cc-uninstall.rb"
  ALIASES

  # ANSI color codes
  RESET = "\e[0m"
  BOLD = "\e[1m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  RED = "\e[31m"

  # Constructor
  def initialize
    @options = {
      action: :detect,
      force: false,
      verbose: false
    }
    
    @phase_dirs = {
      1 => "phase1_ruby",
      2 => "phase2_python",
      3 => "phase3_javascript",
      4 => "phase4_fullstack",
      5 => "phase5_ml_finance"
    }
  end

  # Colorize text
  def colorize(text, color_code)
    return text if ENV['NO_COLOR']
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
      
      opts.on('--update', 'Update an existing installation') do
        @options[:action] = :update
      end
      
      opts.on('--uninstall', 'Remove the installation') do
        @options[:action] = :uninstall
      end
      
      opts.on('-f', '--force', 'Force operation without prompts') do
        @options[:force] = true
      end
      
      opts.on('-v', '--verbose', 'Verbose output') do
        @options[:verbose] = true
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
    Dir.glob(File.join(BIN_DIR, "cc-*.rb")).any?
  end

  # Check if aliases are installed
  def aliases_installed?
    File.exist?(ZSHRC_FILE) && File.read(ZSHRC_FILE).include?(ALIASES_MARKER)
  end

  # Run the installer
  def run
    parse_options
    
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
    else
      puts "Unknown action: #{@options[:action]}"
      exit 1
    end
  end

  # Detect what's already installed
  def detect_installation
    is_installed = false
    
    if File.exist?(CONFIG_FILE)
      is_installed = true
      config = JSON.parse(File.read(CONFIG_FILE)) rescue {}
      current_version = config['version'] || 'unknown'
      puts_info "6/7 Coding Challenge is already installed (version #{current_version})."
    end
    
    if scripts_installed?
      is_installed = true
      puts_info "Scripts are installed in #{BIN_DIR}."
    end
    
    if aliases_installed?
      is_installed = true
      puts_info "Aliases are configured in ~/.zshrc."
    end
    
    if File.exist?(DAY_COUNTER)
      is_installed = true
      current_day = File.read(DAY_COUNTER).strip rescue 'invalid'
      puts_info "Day counter is set to #{current_day}."
    end
    
    if Dir.exist?(BASE_DIR)
      is_installed = true
      puts_info "Project directory exists at #{BASE_DIR}."
    end
    
    if is_installed
      puts "\nIt looks like 6/7 Coding Challenge is already installed."
      puts "What would you like to do?"
      puts ""
      puts "1) Update to the latest version"
      puts "2) Reinstall from scratch"
      puts "3) Uninstall completely"
      puts "4) Exit"
      puts ""
      
      if @options[:force]
        choice = 1 # Default to update if --force is specified
      else
        print "Enter your choice (1-4): "
        choice = gets.strip.to_i
      end
      
      case choice
      when 1
        puts_header "Updating 6/7 Coding Challenge"
        return :update
      when 2
        puts_header "Reinstalling 6/7 Coding Challenge"
        return :install
      when 3
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
    
    # Check for ~/bin directory
    if Dir.exist?(BIN_DIR)
      puts_success "~/bin directory exists."
    else
      puts_info "~/bin directory does not exist. It will be created."
    end
    
    # Check if ~/bin is in PATH
    if ENV['PATH'].split(':').include?(BIN_DIR)
      puts_success "~/bin is in your PATH."
    else
      puts_warning "~/bin is not in your PATH. We'll add it to your .zshrc"
    end
    
    prereqs_ok
  end

  # Install the challenge
  def install
    puts_header "Installing 6/7 Coding Challenge"
    
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
    
    # Create configuration file
    setup_config_file
    
    # Setup git ignore
    setup_gitignore
    
    # Final message
    puts ""
    puts_success "Installation complete!"
    puts_info "To get started, run: source ~/.zshrc && ccstart"
  end

  # Update the challenge
  def update
    puts_header "Updating 6/7 Coding Challenge"
    
    # Backup existing scripts
    backup_scripts
    
    # Update directories
    create_directories
    
    # Ensure bin directory
    setup_bin_directory
    
    # Update script files
    create_script_files
    
    # Ensure aliases
    setup_aliases
    
    # Update configuration file
    update_config_file
    
    # Final message
    puts ""
    puts_success "Update complete!"
    puts_info "Your current progress and day counter have been preserved."
    puts_info "To continue, run: source ~/.zshrc && ccstatus"
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
    if Dir.exist?(BASE_DIR) && !@options[:force]
      print "Do you want to remove the project directory? This will delete all your code and logs. (y/n): "
      remove_dir = gets.strip.downcase == 'y'
    else
      remove_dir = false # Never force remove the project directory
    end
    
    if remove_dir
      FileUtils.rm_rf(BASE_DIR)
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

  # Create the directory structure
  def create_directories
    puts_header "Creating Directory Structure"
    
    # Create base directory
    unless Dir.exist?(BASE_DIR)
      FileUtils.mkdir_p(BASE_DIR)
      puts_success "Created base directory: #{BASE_DIR}"
    end
    
    # Create phase directories
    @phase_dirs.each do |phase, dir_name|
      phase_dir = File.join(BASE_DIR, dir_name)
      unless Dir.exist?(phase_dir)
        FileUtils.mkdir_p(phase_dir)
        puts_success "Created phase directory: #{phase_dir}"
      end
    end
    
    # Create logs directory
    @phase_dirs.each do |phase, _|
      log_dir = File.join(BASE_DIR, 'logs', "phase#{phase}")
      unless Dir.exist?(log_dir)
        FileUtils.mkdir_p(log_dir)
        puts_success "Created log directory: #{log_dir}"
      end
    end
    
    # Create week/day directories for phase 1
    (1..17).each do |week|
      week_formatted = format('%02d', week)
      week_dir = File.join(BASE_DIR, @phase_dirs[1], "week#{week_formatted}")
      
      unless Dir.exist?(week_dir)
        FileUtils.mkdir_p(week_dir)
        puts_success "Created week directory: #{week_dir}" if @options[:verbose]
      end
      
      # For week 1, create day directories to get started
      if week == 1
        (1..6).each do |day|
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
    unless Dir.exist?(BIN_DIR)
      FileUtils.mkdir_p(BIN_DIR)
      puts_success "Created bin directory: #{BIN_DIR}"
    end
    
    # Add to PATH if needed
    unless ENV['PATH'].split(':').include?(BIN_DIR)
      File.open(ZSHRC_FILE, 'a') do |f|
        f.puts 'export PATH="$HOME/bin:$PATH"'
      end
      puts_success "Added ~/bin to PATH in .zshrc"
    end
  end

  # Create script files
  def create_script_files
    puts_header "Creating Script Files"
    
    # Define the scripts we'll create
    scripts = {
      'cc-start-day.rb' => File.read(File.join(File.dirname(__FILE__), 'cc-start-day.rb')),
      'cc-log-progress.rb' => File.read(File.join(File.dirname(__FILE__), 'cc-log-progress.rb')),
      'cc-push-updates.rb' => File.read(File.join(File.dirname(__FILE__), 'cc-push-updates.rb')),
      'cc-status.rb' => File.read(File.join(File.dirname(__FILE__), 'cc-status.rb')),
      'cc-update.rb' => File.read(File.join(File.dirname(__FILE__), 'cc-update.rb')),
      'cc-uninstall.rb' => File.read(File.join(File.dirname(__FILE__), 'cc-uninstall.rb'))
    }
    
    # Check if scripts exist in current directory, if not use embedded scripts
    scripts.each do |filename, content|
      if content.nil? || content.empty?
        local_script = File.join(File.dirname(__FILE__), filename)
        if File.exist?(local_script)
          content = File.read(local_script)
        else
          puts_error "Script content for #{filename} not found."
          exit 1
        end
      end
      
      script_path = File.join(BIN_DIR, filename)
      File.write(script_path, content)
      FileUtils.chmod(0755, script_path) # Make executable
      
      puts_success "Created script: #{script_path}"
    end
  end

  # Backup existing scripts
  def backup_scripts
    if scripts_installed?
      puts_info "Backing up existing scripts..."
      backup_dir = File.join(BIN_DIR, "cc-backup-#{Time.now.strftime('%Y%m%d%H%M%S')}")
      FileUtils.mkdir_p(backup_dir)
      
      Dir.glob(File.join(BIN_DIR, "cc-*.rb")).each do |script|
        FileUtils.cp(script, backup_dir)
      end
      
      puts_success "Existing scripts backed up to #{backup_dir}."
    end
  end

  # Remove script files
  def remove_scripts
    puts_info "Removing script files..."
    Dir.glob(File.join(BIN_DIR, "cc-*.rb")).each do |script|
      File.delete(script)
      puts_success "Removed script: #{script}" if @options[:verbose]
    end
    puts_success "All scripts removed."
  end

  # Set up aliases in .zshrc
  def setup_aliases
    if aliases_installed?
      # Replace existing aliases
      content = File.read(ZSHRC_FILE)
      marker_index = content.index(ALIASES_MARKER)
      
      if marker_index
        # Find the end of the aliases block
        next_line_index = content.index("\n", marker_index + ALIASES_MARKER.length)
        while next_line_index && content[next_line_index + 1] =~ /^alias cc/
          next_line_index = content.index("\n", next_line_index + 1)
        end
        
        # Replace the block
        if next_line_index
          new_content = content[0...marker_index] + ALIASES_BLOCK + content[next_line_index..-1]
          File.write(ZSHRC_FILE, new_content)
          puts_success "Updated aliases in .zshrc"
        end
      end
    else
      # Add new aliases
      File.open(ZSHRC_FILE, 'a') do |f|
        f.puts "\n#{ALIASES_BLOCK}"
      end
      puts_success "Added aliases to .zshrc"
    end
  end

  # Remove aliases from .zshrc
  def remove_aliases
    if aliases_installed?
      puts_info "Removing aliases from .zshrc..."
      content = File.read(ZSHRC_FILE)
      marker_index = content.index(ALIASES_MARKER)
      
      if marker_index
        # Find the end of the aliases block
        next_line_index = content.index("\n", marker_index + ALIASES_MARKER.length)
        while next_line_index && content[next_line_index + 1] =~ /^alias cc/
          next_line_index = content.index("\n", next_line_index + 1)
        end
        
        # Remove the block
        if next_line_index
          new_content = content[0...marker_index] + content[next_line_index..-1]
          File.write(ZSHRC_FILE, new_content)
          puts_success "Removed aliases from .zshrc"
        end
      end
    end
  end

  # Create or update config file
  def setup_config_file
    config = {
      'version' => VERSION,
      'install_date' => Time.now.strftime('%Y-%m-%d'),
      'last_updated' => Time.now.strftime('%Y-%m-%d')
    }
    
    File.write(CONFIG_FILE, JSON.pretty_generate(config))
    puts_success "Created configuration file: #{CONFIG_FILE}"
  end

  # Update config file
  def update_config_file
    if File.exist?(CONFIG_FILE)
      config = JSON.parse(File.read(CONFIG_FILE)) rescue {}
      old_version = config['version'] || 'unknown'
      
      config['version'] = VERSION
      config['last_updated'] = Time.now.strftime('%Y-%m-%d')
      
      File.write(CONFIG_FILE, JSON.pretty_generate(config))
      puts_success "Updated configuration from version #{old_version} to #{VERSION}"
    else
      setup_config_file
    end
  end

  # Setup .gitignore file
  def setup_gitignore
    gitignore_path = File.join(BASE_DIR, '.gitignore')
    
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
      
      # Editor directories and files
      .idea/
      .vscode/
      *.swp
      *.swo
      *~
      *.sublime-workspace
      
      # Environment and config files
      .env
      .env.local
      .env.development.local
      .env.test.local
      .env.production.local
      
      # Ruby specific
      *.gem
      *.rbc
      /.config
      /coverage/
      /InstalledFiles
      /pkg/
      /spec/reports/
      /spec/examples.txt
      /test/tmp/
      /test/version_tmp/
      /tmp/
      .byebug_history
      
      # Python specific
      __pycache__/
      *.py[cod]
      *$py.class
      *.so
      .Python
      env/
      build/
      develop-eggs/
      dist/
      downloads/
      eggs/
      .eggs/
      lib/
      lib64/
      parts/
      sdist/
      var/
      *.egg-info/
      .installed.cfg
      *.egg
      
      # JavaScript specific
      node_modules/
      /build
      .npm
      .eslintcache
      .yarn-integrity
      .cache
      .parcel-cache
      
      # Logs
      logs
      *.log
      npm-debug.log*
      yarn-debug.log*
      yarn-error.log*
    GITIGNORE
    
    if File.exist?(gitignore_path)
      puts_info "Using existing .gitignore file."
    else
      File.write(gitignore_path, gitignore_content)
      puts_success "Created .gitignore file."
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  installer = CodingChallengeInstaller.new
  installer.run
end