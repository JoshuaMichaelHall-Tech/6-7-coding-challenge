#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge Installer
# A Ruby implementation of the setup script
# Author: Joshua Michael Hall

require 'fileutils'
require 'optparse'
require 'json'

class CodingChallengeInstaller
  VERSION = '2.0.0'
  
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

  # Scripts to create
  SCRIPTS = {
    'cc-start-day.rb' => {
      desc: 'Initialize the environment for a new challenge day',
      content: nil # Will be filled in
    },
    'cc-log-progress.rb' => {
      desc: 'Record daily progress in weekly log files',
      content: nil # Will be filled in
    },
    'cc-push-updates.rb' => {
      desc: 'Commit changes and increment the day counter',
      content: nil # Will be filled in
    },
    'cc-status.rb' => {
      desc: 'Display challenge progress and statistics',
      content: nil # Will be filled in
    },
    'cc-update.rb' => {
      desc: 'Update scripts to the latest version',
      content: nil # Will be filled in
    },
    'cc-uninstall.rb' => {
      desc: 'Remove scripts and configuration',
      content: nil # Will be filled in
    }
  }

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
      puts ""
      puts "It looks like 6/7 Coding Challenge is already installed."
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
    
    # Create each script
    SCRIPTS.each do |filename, info|
      script_path = File.join(BIN_DIR, filename)
      
      # Generate the script content
      content = send("generate_#{filename.gsub('.rb', '').gsub('-', '_')}")
      
      # Write the script
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

  # Generate start day script
  def generate_cc_start_day
    <<~RUBY
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      
      # 6/7 Coding Challenge - Start Day Script
      # Initializes the environment for a new challenge day
      
      require 'fileutils'
      require 'date'
      
      # Constants
      HOME_DIR = ENV['HOME']
      BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
      DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
      
      # Get current day
      unless File.exist?(DAY_COUNTER)
        puts "Error: Day counter file not found. Creating with default value of 1."
        File.write(DAY_COUNTER, "1")
      end
      
      CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i
      PHASE = ((CURRENT_DAY - 1) / 100) + 1
      WEEK_IN_PHASE = (((CURRENT_DAY - 1) % 100) / 6) + 1
      DAY_OF_WEEK = Date.today.cwday # 1-7, where 1 is Monday and 7 is Sunday
      
      # Check if it's Sunday
      if DAY_OF_WEEK == 7
        puts "Today is the Sabbath. Time for rest, not coding."
        exit 0
      end
      
      # Format week with leading zero
      WEEK_FORMATTED = format('%02d', WEEK_IN_PHASE)
      
      # Set phase directory
      PHASE_DIRS = {
        1 => "phase1_ruby",
        2 => "phase2_python",
        3 => "phase3_javascript",
        4 => "phase4_fullstack",
        5 => "phase5_ml_finance"
      }
      
      PHASE_DIR = PHASE_DIRS[PHASE]
      
      # Check if base directory exists
      unless Dir.exist?(BASE_DIR)
        puts "Error: Base project directory not found at \#{BASE_DIR}"
        puts "Please run the setup script first."
        exit 1
      end
      
      # Create directories if needed
      PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week\#{WEEK_FORMATTED}", "day\#{CURRENT_DAY}")
      FileUtils.mkdir_p(PROJECT_DIR)
      
      LOG_DIR = File.join(BASE_DIR, 'logs', "phase\#{PHASE}")
      FileUtils.mkdir_p(LOG_DIR)
      
      # Initialize log file if needed
      LOG_FILE = File.join(LOG_DIR, "week\#{WEEK_FORMATTED}.md")
      
      unless File.exist?(LOG_FILE)
        puts "Creating new log file: \#{LOG_FILE}"
        week_start = ((WEEK_IN_PHASE - 1) * 6) + 1
        week_end = WEEK_IN_PHASE * 6
        
        File.open(LOG_FILE, 'w') do |f|
          f.puts "# Week \#{WEEK_FORMATTED} (Days \#{week_start}-\#{week_end})"
          f.puts ""
          f.puts "## Week Overview"
          f.puts "- **Focus**: "
          f.puts "- **Launch School Connection**: "
          f.puts "- **Weekly Goals**:"
          f.puts "  - "
          f.puts "  - "
          f.puts "  - "
          f.puts ""
          f.puts "## Daily Logs"
          f.puts ""
        end
      end
      
      # Set up the day's work if README doesn't exist
      README_PATH = File.join(PROJECT_DIR, 'README.md')
      
      unless File.exist?(README_PATH)
        puts "Setting up Day \#{CURRENT_DAY} (Phase \#{PHASE}, Week \#{WEEK_FORMATTED})"
        
        File.open(README_PATH, 'w') do |f|
          f.puts "# Day \#{CURRENT_DAY} - Phase \#{PHASE} (Week \#{WEEK_FORMATTED})"
          f.puts ""
          f.puts "## Today's Focus"
          f.puts "- [ ] Primary goal: "
          f.puts "- [ ] Secondary goal:"
          f.puts "- [ ] Stretch goal:"
          f.puts ""
          f.puts "## Launch School Connection"
          f.puts "- Current course: "
          f.puts "- Concept application: "
          f.puts ""
          f.puts "## Progress Log"
          f.puts "- Started: \#{Time.now.strftime('%Y-%m-%d %H:%M')}"
          f.puts "- "
          f.puts ""
          f.puts "## Reflections"
          f.puts "-"
          f.puts ""
        end
      else
        puts "Using existing README for Day \#{CURRENT_DAY}"
      end
      
      # Determine editor
      if system("which nvim > /dev/null 2>&1")
        EDITOR = "nvim"
      elsif system("which vim > /dev/null 2>&1")
        EDITOR = "vim"
      else
        EDITOR = ENV['EDITOR'] || "vi"
      end
      
      # Check if tmux is installed
      if system("which tmux > /dev/null 2>&1")
        # Kill existing session if it exists
        system("tmux has-session -t coding-challenge 2>/dev/null && tmux kill-session -t coding-challenge")
        
        # Change to project directory
        Dir.chdir(PROJECT_DIR)
        
        # Start tmux session
        puts "Starting tmux session..."
        exec "tmux new-session -s coding-challenge '\#{EDITOR} README.md'"
      else
        puts "Warning: tmux is not installed. Opening project directory without tmux."
        Dir.chdir(PROJECT_DIR)
        exec "\#{EDITOR} README.md"
      end
    RUBY
  end

  # Generate log progress script
  def generate_cc_log_progress
    <<~RUBY
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      
      # 6/7 Coding Challenge - Log Progress Script
      # Records daily progress in weekly log files
      # Supports retroactive logging for previous days
      
      require 'fileutils'
      
      # Constants
      HOME_DIR = ENV['HOME']
      BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
      DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
      
      # Process command line arguments
      if ARGV[0] && ARGV[0] =~ /^\\d+$/
        LOG_DAY = ARGV[0].to_i
        puts "Logging for specified day: \#{LOG_DAY}"
      else
        # If no day specified, use current day counter
        unless File.exist?(DAY_COUNTER)
          puts "Error: Day counter file not found. Run setup script first."
          exit 1
        end
        
        LOG_DAY = File.read(DAY_COUNTER).strip.to_i
        puts "Logging for current day: \#{LOG_DAY}"
      end
      
      # Validate the day number
      if LOG_DAY < 1
        puts "Error: Invalid day number. Days start from 1."
        exit 1
      end
      
      CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i
      if LOG_DAY > CURRENT_DAY
        puts "Error: Cannot log for future days. Current day is \#{CURRENT_DAY}."
        exit 1
      end
      
      # Calculate phase, week based on the day to log
      PHASE = ((LOG_DAY - 1) / 100) + 1
      WEEK_IN_PHASE = (((LOG_DAY - 1) % 100) / 6) + 1
      
      # Format week with leading zero
      WEEK_FORMATTED = format('%02d', WEEK_IN_PHASE)
      
      # Set phase directory
      PHASE_DIRS = {
        1 => "phase1_ruby",
        2 => "phase2_python",
        3 => "phase3_javascript",
        4 => "phase4_fullstack",
        5 => "phase5_ml_finance"
      }
      
      PHASE_DIR = PHASE_DIRS[PHASE]
      
      # Check if base directory exists
      unless Dir.exist?(BASE_DIR)
        puts "Error: Base project directory not found at \#{BASE_DIR}"
        puts "Please run the setup script first."
        exit 1
      end
      
      # Set paths
      PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week\#{WEEK_FORMATTED}", "day\#{LOG_DAY}")
      LOG_FILE = File.join(BASE_DIR, 'logs', "phase\#{PHASE}", "week\#{WEEK_FORMATTED}.md")

      # Check if project directory exists
      unless Dir.exist?(PROJECT_DIR)
        puts "Error: Project directory not found at \#{PROJECT_DIR}"
        puts "Please make sure you've initialized this day with ccstart."
        exit 1
      end

      # Check if README exists
      README_PATH = File.join(PROJECT_DIR, 'README.md')
      unless File.exist?(README_PATH)
        puts "Error: README.md not found in \#{PROJECT_DIR}"
        puts "Please make sure you've initialized this day with ccstart."
        exit 1
      end

      # Read README content
      readme_content = File.read(README_PATH)
      
      # Create log directory if needed
      log_dir = File.dirname(LOG_FILE)
      FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)

      # Check if log file exists, create if not
      unless File.exist?(LOG_FILE)
        puts "Creating new log file: \#{LOG_FILE}"
        week_start = ((WEEK_IN_PHASE - 1) * 6) + 1
        week_end = WEEK_IN_PHASE * 6
        
        File.open(LOG_FILE, 'w') do |f|
          f.puts "# Week \#{WEEK_FORMATTED} (Days \#{week_start}-\#{week_end})"
          f.puts ""
          f.puts "## Week Overview"
          f.puts "- **Focus**: "
          f.puts "- **Launch School Connection**: "
          f.puts "- **Weekly Goals**:"
          f.puts "  - "
          f.puts "  - "
          f.puts "  - "
          f.puts ""
          f.puts "## Daily Logs"
          f.puts ""
        end
      end

      # Check if day entry already exists
      log_content = File.read(LOG_FILE)
      day_entry_pattern = /^## Day #{LOG_DAY}$/

      if log_content.match(day_entry_pattern)
        puts "Warning: An entry for Day \#{LOG_DAY} already exists in the log file."
        print "Do you want to replace it? (y/n): "
        replace_entry = STDIN.gets.chomp.downcase
        
        if replace_entry != 'y'
          puts "Operation canceled."
          exit 0
        end
        
        # Remove existing entry
        lines = log_content.split("\n")
        start_index = lines.find_index { |line| line.match(day_entry_pattern) }
        
        if start_index
          # Find the end of this entry (next day entry or end of file)
          end_index = lines[start_index+1..-1].find_index { |line| line.match(/^## Day \d+$/) }
          
          if end_index
            end_index += start_index + 1 # Adjust for the slice from start_index+1
          else
            end_index = lines.length
          end
          
          # Remove the entry
          lines.slice!(start_index...end_index)
          
          # Write updated content back
          File.write(LOG_FILE, lines.join("\n"))
          puts "Removed existing entry for Day \#{LOG_DAY}"
        end
      end

      # Find the right spot to insert the new entry (entries should be in chronological order)
      lines = File.readlines(LOG_FILE, chomp: true)
      day_entries = lines.each_with_index.select { |line, _| line.match(/^## Day \d+$/) }
      
      insert_index = nil
      inserted = false
      
      day_entries.each do |entry, index|
        entry_day = entry.match(/^## Day (\d+)$/)[1].to_i
        if LOG_DAY < entry_day
          insert_index = index
          inserted = true
          break
        end
      end
      
      if inserted
        # Insert at the appropriate spot
        day_entry = "## Day \#{LOG_DAY}"
        lines.insert(insert_index, day_entry)
      else
        # Append to the end
        day_entry = "## Day \#{LOG_DAY}"
        # Find the last daily log entry or the Daily Logs header
        last_entry_index = day_entries.empty? ? 
          lines.find_index { |line| line.match(/^## Daily Logs$/) } : 
          day_entries.last[1]
          
        if last_entry_index
          # Find the next section after the last entry
          next_section_index = lines[last_entry_index+1..-1].find_index { |line| line.match(/^## /) }
          
          if next_section_index
            insert_index = last_entry_index + 1 + next_section_index
            lines.insert(insert_index, "", day_entry)
          else
            lines << "" << day_entry
          end
        else
          lines << "" << day_entry
        end
      end
      
      # Extract sections from README
      focus_section = extract_section(readme_content, "Today's Focus", "Launch School Connection")
      ls_section = extract_section(readme_content, "Launch School Connection", "Progress Log")
      progress_section = extract_section(readme_content, "Progress Log", "Reflections")
      reflections_section = extract_section(readme_content, "Reflections", nil)
      
      # Find the index right after the day entry
      day_index = lines.find_index { |line| line == day_entry }
      
      if day_index
        # Insert content after the day entry
        current_index = day_index + 1
        
        # Add focus section
        focus_lines = focus_section.split("\n")
        lines.insert(current_index, *focus_lines)
        current_index += focus_lines.length
        
        # Add LS section
        ls_lines = ls_section.split("\n")
        lines.insert(current_index, *ls_lines)
        current_index += ls_lines.length
        
        # Add progress section
        progress_lines = progress_section.split("\n")
        lines.insert(current_index, *progress_lines)
        current_index += progress_lines.length
        
        # Add reflections section
        lines.insert(current_index, "### Reflections")
        reflections_lines = reflections_section.split("\n")
        lines.insert(current_index + 1, *reflections_lines)
        current_index += reflections_lines.length + 1
        
        # Add blank line
        lines.insert(current_index, "")
      end
      
      # Write updated content
      File.write(LOG_FILE, lines.join("\n"))
      
      puts "Progress for Day \#{LOG_DAY} successfully logged to \#{LOG_FILE}"

      # Helper method to extract section from README
      def extract_section(content, section_start, section_end)
        pattern_start = "## #{section_start}"
        pattern_end = section_end ? "## #{section_end}" : nil
        
        start_index = content.index(pattern_start)
        return "" unless start_index
        
        if pattern_end
          end_index = content.index(pattern_end, start_index)
          return "" unless end_index
          
          section = content[start_index...end_index]
        else
          section = content[start_index..-1]
        end
        
        # Remove the header itself
        section = section.sub(pattern_start, "").strip
        
        # Return the section
        section
      end
    RUBY
  end

  # Generate push updates script
  def generate_cc_push_updates
    <<~RUBY
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      
      # 6/7 Coding Challenge - Push Updates Script
      # Commits changes and increments the day counter
      
      require 'fileutils'
      
      # Constants
      HOME_DIR = ENV['HOME']
      BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
      DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
      
      # Check if day counter exists
      unless File.exist?(DAY_COUNTER)
        puts "Error: Day counter file not found. Run setup script first."
        exit 1
      end
      
      # Get current day
      CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i
      
      # Check if base directory exists
      unless Dir.exist?(BASE_DIR)
        puts "Error: Base project directory not found at \#{BASE_DIR}"
        puts "Please run the setup script first."
        exit 1
      end
      
      # Check if it's a git repository
      unless Dir.exist?(File.join(BASE_DIR, '.git'))
        puts "Error: Not a git repository. Please init git first."
        puts "cd \#{BASE_DIR} && git init"
        exit 1
      end
      
      # Move to the repository directory
      Dir.chdir(BASE_DIR)
      
      # Check if there are any changes to commit
      if system("git diff --quiet && git diff --staged --quiet")
        puts "No changes to commit. Have you made any progress today?"
        print "Proceed anyway? (y/n): "
        proceed = STDIN.gets.chomp.downcase
        
        if proceed != 'y'
          puts "Operation canceled."
          exit 0
        end
      end
      
      # Get commit message with date
      commit_date = Time.now.strftime("%Y-%m-%d")
      commit_msg = "Day \#{CURRENT_DAY}: \#{commit_date}"
      
      # Additional commit details
      PHASE = ((CURRENT_DAY - 1) / 100) + 1
      WEEK_IN_PHASE = (((CURRENT_DAY - 1) % 100) / 6) + 1
      WEEK_FORMATTED = format('%02d', WEEK_IN_PHASE)
      
      # Determine phase name
      PHASE_NAMES = {
        1 => "Ruby Backend",
        2 => "Python Data Analysis",
        3 => "JavaScript Frontend",
        4 => "Full-Stack Projects",
        5 => "ML Finance Applications"
      }
      
      PHASE_NAME = PHASE_NAMES[PHASE] || "Unknown Phase"
      
      # Add project directory info to commit message
      PHASE_DIRS = {
        1 => "phase1_ruby",
        2 => "phase2_python",
        3 => "phase3_javascript",
        4 => "phase4_fullstack",
        5 => "phase5_ml_finance"
      }
      
      PHASE_DIR = PHASE_DIRS[PHASE]
      PROJECT_DIR = File.join(BASE_DIR, PHASE_DIR, "week\#{WEEK_FORMATTED}", "day\#{CURRENT_DAY}")
      
      if Dir.exist?(PROJECT_DIR)
        # Extract focus from README
        readme_path = File.join(PROJECT_DIR, 'README.md')
        
        if File.exist?(readme_path)
          readme_content = File.read(readme_path)
          primary_goal_match = readme_content.match(/Primary goal: (.+)/)
          
          if primary_goal_match
            primary_goal = primary_goal_match[1].strip
            commit_msg = "\#{commit_msg} - \#{primary_goal}"
          end
        end
      end
      
      # Add files to git
      puts "Adding files to git..."
      system("git add .")
      
      # Commit changes
      puts "Committing changes with message: \#{commit_msg}"
      system("git commit -m \"\#{commit_msg}\"")
      
      # Check if remote exists
      if system("git remote -v | grep -q origin")
        puts "Pushing to remote repository..."
        system("git push origin main")
      else
        puts "Warning: No remote 'origin' found. Set up a remote to push your progress."
        puts "git remote add origin YOUR_REPOSITORY_URL"
      end
      
      # Increment day counter
      puts "Incrementing day counter from \#{CURRENT_DAY} to \#{CURRENT_DAY + 1}..."
      File.write(DAY_COUNTER, (CURRENT_DAY + 1).to_s)
      
      # Success message
      puts "===================="
      puts "Updates successfully pushed and day counter incremented"
      puts "Current progress: Day \#{CURRENT_DAY}/500 completed (\#{((CURRENT_DAY - 1) * 100 / 500)}%)"
      puts "Phase \#{PHASE}: \#{PHASE_NAME}"
      puts "Tomorrow is Day \#{CURRENT_DAY + 1}"
      puts "===================="
    RUBY
  end

  # Generate status script
  def generate_cc_status
    <<~RUBY
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      
      # 6/7 Coding Challenge - Status Script
      # Displays challenge progress and statistics
      
      require 'date'
      
      # Constants
      HOME_DIR = ENV['HOME']
      BASE_DIR = File.join(HOME_DIR, 'projects', '6-7-coding-challenge')
      DAY_COUNTER = File.join(HOME_DIR, '.cc-current-day')
      
      # Check if day counter exists
      unless File.exist?(DAY_COUNTER)
        puts "Error: Day counter file not found. Run setup script first."
        exit 1
      end
      
      # Get current day
      CURRENT_DAY = File.read(DAY_COUNTER).strip.to_i
      
      # Calculate progress metrics
      TOTAL_DAYS = 500
      DAYS_REMAINING = TOTAL_DAYS - CURRENT_DAY + 1
      PERCENT_COMPLETE = ((CURRENT_DAY - 1) * 100 / TOTAL_DAYS)
      
      PHASE = ((CURRENT_DAY - 1) / 100) + 1
      WEEK_IN_PHASE = (((CURRENT_DAY - 1) % 100) / 6) + 1
      DAY_IN_WEEK = ((CURRENT_DAY - 1) % 6) + 1
      WEEK_OVERALL = ((CURRENT_DAY - 1) / 6) + 1
      
      # Determine phase name
      PHASE_NAMES = {
        1 => "Ruby Backend",
        2 => "Python Data Analysis",
        3 => "JavaScript Frontend",
        4 => "Full-Stack Projects",
        5 => "ML Finance Applications"
      }
      
      PHASE_NAME = PHASE_NAMES[PHASE] || "Unknown Phase"
      
      # Calculate completion date
      begin
        completion_date = Date.today + DAYS_REMAINING
        COMPLETION_DATE = completion_date.strftime("%Y-%m-%d")
      rescue
        COMPLETION_DATE = "Unknown (date calculation error)"
      end
      
      # Calculate schedule status
      START_DATE = Date.new(2025, 4, 1) # Challenge start date
      CURRENT_DATE = Date.today
      
      begin
        days_elapsed = (CURRENT_DATE - START_DATE).to_i
        
        # Adjust for Sundays (don't count them in the challenge)
        weeks_elapsed = days_elapsed / 7
        sundays_elapsed = weeks_elapsed
        actual_days_elapsed = days_elapsed - sundays_elapsed
        
        # Calculate expected day vs actual day
        expected_day = actual_days_elapsed + 1
        day_difference = CURRENT_DAY - expected_day
        
        if day_difference > 0
          DAY_STATUS = "Ahead of schedule by \#{day_difference} day(s)"
        elsif day_difference < 0
          DAY_STATUS = "Behind schedule by \#{-day_difference} day(s)"
        else
          DAY_STATUS = "On schedule"
        end
        
        DAYS_ELAPSED = actual_days_elapsed
      rescue
        DAYS_ELAPSED = "Unknown"
        DAY_STATUS = "Status calculation not supported"
      end
      
      # Console colors
      if STDOUT.tty?
        BOLD = "\e[1m"
        GREEN = "\e[32m"
        YELLOW = "\e[33m"
        BLUE = "\e[34m"
        MAGENTA = "\e[35m"
        CYAN = "\e[36m"
        RESET = "\e[0m"
      else
        BOLD = ""
        GREEN = ""
        YELLOW = ""
        BLUE = ""
        MAGENTA = ""
        CYAN = ""
        RESET = ""
      end
      
      # Print status with colorized output
      puts "\#{BOLD}╔═══════════════════════════════════════════════════╗\#{RESET}"
      puts "\#{BOLD}║            6/7 CODING CHALLENGE STATUS             ║\#{RESET}"
      puts "\#{BOLD}╠═══════════════════════════════════════════════════╣\#{RESET}"
      printf "\#{BOLD}║\#{RESET} \#{GREEN}Current Day:\#{RESET} %-37s \#{BOLD}║\#{RESET}\\n", "\#{CURRENT_DAY}/500"
      printf "\#{BOLD}║\#{RESET} \#{BLUE}Phase:\#{RESET} %-43s \#{BOLD}║\#{RESET}\\n", "\#{PHASE} of 5 - \#{PHASE_NAME}"
      printf "\#{BOLD}║\#{RESET} \#{MAGENTA}Week:\#{RESET} %-44s \#{BOLD}║\#{RESET}\\n", "\#{WEEK_OVERALL} overall (Week \#{WEEK_IN_PHASE} in Phase \#{PHASE})"
      printf "\#{BOLD}║\#{RESET} \#{CYAN}Day of Week:\#{RESET} %-37s \#{BOLD}║\#{RESET}\\n", "\#{DAY_IN_WEEK}/6"
      printf "\#{BOLD}║\#{RESET} \#{YELLOW}Progress:\#{RESET} %-40s \#{BOLD}║\#{RESET}\\n", "\#{PERCENT_COMPLETE}% complete"
      printf "\#{BOLD}║\#{RESET} \#{GREEN}Days Elapsed:\#{RESET} %-35s \#{BOLD}║\#{RESET}\\n", "\#{DAYS_ELAPSED}"
      printf "\#{BOLD}║\#{RESET} \#{GREEN}Schedule Status:\#{RESET} %-32s \#{BOLD}║\#{RESET}\\n", "\#{DAY_STATUS}"
      printf "\#{BOLD}║\#{RESET} \#{BLUE}Days Remaining:\#{RESET} %-34s \#{BOLD}║\#{RESET}\\n", "\#{DAYS_REMAINING}"
      printf "\#{BOLD}║\#{RESET} \#{MAGENTA}Estimated Completion:\#{RESET} %-29s \#{BOLD}║\#{RESET}\\n", "\#{COMPLETION_DATE}"
      
      # Calculate and display streaks
      if Dir.exist?(File.join(BASE_DIR, '.git'))
        Dir.chdir(BASE_DIR)
        current_streak = 0
        
        begin
          yesterday = Date.today - 1
          
          while true
            yesterday_str = yesterday.strftime("%Y-%m-%d")
            has_commit = system("git log --since=\"\#{yesterday_str}\" --until=\"\#{yesterday_str} 23:59:59\" --pretty=format:%H | grep -q .", out: File::NULL, err: File::NULL)
            
            break unless has_commit
            
            current_streak += 1
            yesterday = yesterday - 1
            
            # Skip Sundays in streak calculation
            if yesterday.cwday == 7
              yesterday = yesterday - 1
            end
          end
          
          printf "\#{BOLD}║\#{RESET} \#{CYAN}Current Streak:\#{RESET} %-34s \#{BOLD}║\#{RESET}\\n", "\#{current_streak} day(s)"
        rescue
          # Ignore streak calculation errors
        end
      end
      
      # Add repository information
      if Dir.exist?(File.join(BASE_DIR, '.git'))
        Dir.chdir(BASE_DIR)
        
        branch = `git branch --show-current 2>/dev/null`.strip
        branch = "Unknown" if branch.empty?
        
        last_commit = `git log -1 --pretty=format:"%h - %s" 2>/dev/null`.strip
        last_commit = "No commits yet" if last_commit.empty?
        
        last_commit_date = `git log -1 --pretty=format:"%cd" --date=short 2>/dev/null`.strip
        last_commit_date = "N/A" if last_commit_date.empty?
        
        puts "\#{BOLD}╠═══════════════════════════════════════════════════╣\#{RESET}"
        printf "\#{BOLD}║\#{RESET} \#{YELLOW}Active Branch:\#{RESET} %-35s \#{BOLD}║\#{RESET}\\n", "\#{branch}"
        printf "\#{BOLD}║\#{RESET} \#{GREEN}Last Commit:\#{RESET} %-37s \#{BOLD}║\#{RESET}\\n", "\#{last_commit}"
        printf "\#{BOLD}║\#{RESET} \#{BLUE}Commit Date:\#{RESET} %-36s \#{BOLD}║\#{RESET}\\n", "\#{last_commit_date}"
      end
      
      puts "\#{BOLD}╚═══════════════════════════════════════════════════╝\#{RESET}"
    RUBY
  end

  # Generate update script
  def generate_cc_update
    <<~RUBY
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      
      # 6/7 Coding Challenge - Update Script
      # Updates scripts to the latest version
      
      # This script simply calls the installer with the update option
      installer_path = File.join(ENV['HOME'], 'bin', 'cc-installer.rb')
      
      # Check if the installer exists
      unless File.exist?(installer_path)
        puts "Error: Installer not found at \#{installer_path}"
        puts "Please run cc-installer.rb with --update option manually."
        exit 1
      end
      
      # Execute the installer with the update option
      puts "Running the installer with the update option..."
      exec "ruby \#{installer_path} --update"
    RUBY
  end

  # Generate uninstall script
  def generate_cc_uninstall
    <<~RUBY
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      
      # 6/7 Coding Challenge - Uninstall Script
      # Removes scripts and configuration
      
      # This script simply calls the installer with the uninstall option
      installer_path = File.join(ENV['HOME'], 'bin', 'cc-installer.rb')
      
      # Check if the installer exists
      unless File.exist?(installer_path)
        puts "Error: Installer not found at \#{installer_path}"
        puts "Please run cc-installer.rb with --uninstall option manually."
        exit 1
      end
      
      # Execute the installer with the uninstall option
      puts "Running the installer with the uninstall option..."
      exec "ruby \#{installer_path} --uninstall"
    RUBY
  end

  # Helper methods
  def command_exists?(command)
    system("which #{command} > /dev/null 2>&1")
  end

  def scripts_installed?
    SCRIPTS.keys.all? do |script|
      File.exist?(File.join(BIN_DIR, script))
    end
  end

  def aliases_installed?
    return false unless File.exist?(ZSHRC_FILE)
    File.read(ZSHRC_FILE).include?(ALIASES_MARKER)
  end

  # Console output formatting helpers
  def puts_header(message)
    puts "\n=== #{message} ==="
  end

  def puts_success(message)
    puts "✓ #{message}"
  end

  def puts_warning(message)
    puts "⚠ #{message}"
  end

  def puts_error(message)
    puts "✗ #{message}"
  end

  def puts_info(message)
    puts "ℹ #{message}"
  end
end

# Run the installer if executed directly
if __FILE__ == $PROGRAM_NAME
  CodingChallengeInstaller.new.run
end
