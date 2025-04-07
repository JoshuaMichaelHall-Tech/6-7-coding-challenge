#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Installer Script
# A Ruby implementation of the setup script for 6/7 Coding Challenge
# Version 3.0.0 - Updated for configuration flexibility

require 'fileutils'
require 'optparse'
require 'json'
require_relative '../lib/cc_config'

class CodingChallengeInstaller
  VERSION = '3.0.0'
  
  # Constructor
  def initialize
    @options = {
      action: :detect,
      force: false,
      verbose: false,
      interactive: true
    }
  end

  # Colorize text
  def colorize(text, color_code)
    return text unless CCConfig.use_colors?
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
    Dir.glob(File.join(CCConfig.bin_dir, "cc-*.rb")).any?
  end

  # Check if aliases are installed
  def aliases_installed?
    zshrc_file = File.join(ENV['HOME'], '.zshrc')
    File.exist?(zshrc_file) && File.read(zshrc_file).include?('# 6/7 Coding Challenge aliases')
  end

  # Run the installer
  def run
    parse_options
    
    # Load existing config or create default
    @config = CCConfig.load
    
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
    
    # Check for config file
    if File.exist?(CCConfig::CONFIG_FILE)
      is_installed = true
      puts_info "6/7 Coding Challenge is already installed (version #{@config['version']})."
    end
    
    # Check for scripts
    if scripts_installed?
      is_installed = true
      puts_info "Scripts are installed in #{CCConfig.bin_dir}."
    end
    
    # Check for aliases
    if aliases_installed?
      is_installed = true
      puts_info "Aliases are configured in ~/.zshrc."
    end
    
    # Check for day counter
    if File.exist?(CCConfig::DAY_COUNTER)
      is_installed = true
      puts_info "Day counter is set to #{CCConfig.current_day}."
    end
    
    # Check for project directory
    if Dir.exist?(CCConfig.base_dir)
      is_installed = true
      puts_info "Project directory exists at #{CCConfig.base_dir}."
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
      puts "3) Uninstall completely"
      puts "4) Exit"
      puts ""
      
      print "Enter your choice (1-4): "
      choice = gets.strip.to_i
      
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
    
    # Save updated config
    CCConfig.save(@config)
    puts_success "Configuration saved to #{CCConfig::CONFIG_FILE}"
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
    
    # Final message
    puts ""
    puts_success "Installation complete!"
    puts_info "To get started, run: source ~/.zshrc && ccstart"
  end

  # Set up or preserve the day counter
  def setup_day_counter
    if File.exist?(CCConfig::DAY_COUNTER)
      # Keep existing counter
      current_day = CCConfig.current_day
      puts_info "Using existing day counter: #{current_day}"
    else
      # Create new counter
      CCConfig.update_day(1)
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
    
    # Add to PATH if needed
    unless ENV['PATH'].split(':').include?(bin_dir)
      zshrc_file = File.join(ENV['HOME'], '.zshrc')
      File.open(zshrc_file, 'a') do |f|
        f.puts 'export PATH="$HOME/bin:$PATH"'
      end
      puts_success "Added bin directory to PATH in .zshrc"
    end
  end

  # Create script files
  def create_script_files
    puts_header "Creating Script Files"
    
    # Define the scripts to create and their source files
    scripts = {
      'cc-start-day.rb' => 'scripts/cc-start-day.rb',
      'cc-log-progress.rb' => 'scripts/cc-log-progress.rb',
      'cc-push-updates.rb' => 'scripts/cc-push-updates.rb',
      'cc-status.rb' => 'scripts/cc-status.rb',
      'cc-config.rb' => 'scripts/cc-config.rb',
      'cc-update.rb' => 'scripts/cc-update.rb',
      'cc-uninstall.rb' => 'scripts/cc-uninstall.rb'
    }
    
    bin_dir = @config['paths']['bin_dir']
    
    # Create lib directory if it doesn't exist
    lib_dir = File.join(bin_dir, 'lib')
    FileUtils.mkdir_p(lib_dir)
    
    # Copy the configuration module
    config_module_source = 'lib/cc_config.rb'
    config_module_dest = File.join(lib_dir, 'cc_config.rb')
    
    if File.exist?(config_module_source)
      FileUtils.cp(config_module_source, config_module_dest)
      FileUtils.chmod(0755, config_module_dest)
      puts_success "Created module: #{config_module_dest}"
    else
      puts_error "Configuration module not found: #{config_module_source}"
      exit 1
    end
    
    # Process each script
    scripts.each do |script_name, source_file|
      if File.exist?(source_file)
        script_content = File.read(source_file)
        
        # Update paths if needed
        script_content.gsub!(/require_relative 'lib\/cc_config'/, "require_relative 'lib/cc_config'")
        
        script_path = File.join(bin_dir, script_name)
        File.write(script_path, script_content)
        FileUtils.chmod(0755, script_path)
        
        puts_success "Created script: #{script_path}"
      else
        puts_error "Script source not found: #{source_file}"
      end
    end
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
    
    # Update configuration
    @config['version'] = VERSION
    @config['installation']['last_updated'] = Time.now.strftime('%Y-%m-%d')
    CCConfig.save(@config)
    
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
    if File.exist?(CCConfig::DAY_COUNTER) && !@options[:force]
      print "Do you want to remove the day counter? This will reset your progress. (y/n): "
      remove_counter = gets.strip.downcase == 'y'
    else
      remove_counter = @options[:force]
    end
    
    if remove_counter
      if File.exist?(CCConfig::DAY_COUNTER)
        File.delete(CCConfig::DAY_COUNTER)
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
    if File.exist?(CCConfig::CONFIG_FILE)
      File.delete(CCConfig::CONFIG_FILE)
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

  # Set up aliases in .zshrc
  def setup_aliases
    zshrc_file = File.join(ENV['HOME'], '.zshrc')
    bin_dir = @config['paths']['bin_dir']
    
    # Aliases block
    aliases_marker = '# 6/7 Coding Challenge aliases'
    aliases_block = <<~ALIASES
      #{aliases_marker}
      alias ccstart="#{bin_dir}/cc-start-day.rb"
      alias cclog="#{bin_dir}/cc-log-progress.rb"
      alias ccpush="#{bin_dir}/cc-push-updates.rb"
      alias ccstatus="#{bin_dir}/cc-status.rb"
      alias ccconfig="#{bin_dir}/cc-config.rb"
      alias ccupdate="#{bin_dir}/cc-update.rb"
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
    zshrc_file = File.join(ENV['HOME'], '.zshrc')
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
  
  # ANSI color codes
  RESET = "\e[0m"
  BOLD = "\e[1m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN = "\e[36m"
  RED = "\e[31m"
end

if __FILE__ == $PROGRAM_NAME
  installer = CodingChallengeInstaller.new
  installer.run
end