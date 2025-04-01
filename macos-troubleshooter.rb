#!/usr/bin/env ruby
# frozen_string_literal: true

# MacOS System Troubleshooter
# A comprehensive system diagnostic and repair tool
# Author: Joshua Michael Hall

require 'json'
require 'English'
require 'fileutils'
require 'optparse'
require 'yaml'
require 'time'
require 'logger'

class MacOSTroubleshooter
  VERSION = '1.0.0'
  LOGS_DIR = File.expand_path('~/.macos_troubleshooter/logs')
  CONFIG_PATH = File.expand_path('~/.macos_troubleshooter/config.yml')

  DIAGNOSTIC_COMMANDS = {
    system_info: {
      command: 'system_profiler SPSoftwareDataType SPHardwareDataType',
      description: 'Basic system information'
    },
    disk_space: {
      command: 'df -h',
      description: 'Disk space usage'
    },
    memory_usage: {
      command: 'vm_stat && top -l 1 -n 0 | grep PhysMem',
      description: 'Memory usage statistics'
    },
    network_status: {
      command: 'networksetup -listallhardwareports && ifconfig && ping -c 3 google.com',
      description: 'Network interface status and connectivity test'
    },
    running_processes: {
      command: 'ps aux | sort -nrk 3,3 | head -20',
      description: 'Top 20 CPU-intensive processes'
    },
    system_load: {
      command: 'sysctl -n vm.loadavg && iostat',
      description: 'System load and I/O statistics'
    },
    launch_agents: {
      command: 'ls -la ~/Library/LaunchAgents /Library/LaunchAgents /Library/LaunchDaemons',
      description: 'List of launch agents and daemons'
    },
    recent_crashes: {
      command: 'find ~/Library/Logs/DiagnosticReports -type f -mtime -7 | head -20',
      description: 'Recent application crashes'
    },
    system_logs: {
      command: 'log show --predicate "eventMessage contains \\"error\\" OR eventMessage contains \\"fail\\"" --last 1h | tail -100',
      description: 'Recent system log errors'
    },
    open_files: {
      command: 'lsof | grep -v "^COMMAND\\|grep" | wc -l',
      description: 'Total open file descriptors'
    }
  }

  REPAIR_COMMANDS = {
    clear_dns_cache: {
      command: 'sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder',
      description: 'Clear DNS cache',
      sudo: true
    },
    repair_disk_permissions: {
      command: 'sudo diskutil repairPermissions /',
      description: 'Repair disk permissions',
      sudo: true
    },
    rebuild_spotlight_index: {
      command: 'sudo mdutil -E /',
      description: 'Rebuild Spotlight index',
      sudo: true
    },
    clear_font_cache: {
      command: 'sudo atsutil databases -remove',
      description: 'Clear font cache',
      sudo: true
    },
    verify_system_files: {
      command: 'sudo /usr/libexec/repair_packages --verify --standard-pkgs --volume /',
      description: 'Verify system files integrity',
      sudo: true
    },
    restart_finder: {
      command: 'killall Finder',
      description: 'Restart Finder',
      sudo: false
    },
    clear_nvram: {
      command: 'echo "Instruction: Restart your Mac and hold Command+Option+P+R until you hear the startup sound twice"',
      description: 'Instructions to clear NVRAM',
      sudo: false,
      manual: true
    },
    clear_application_cache: {
      command: 'find ~/Library/Caches -type d -exec rm -rf {} \\; 2>/dev/null || true',
      description: 'Clear user application caches',
      sudo: false,
      dangerous: true
    },
    full_system_scan: {
      command: 'sudo tmutil verifychecksums / && sudo fsck -fy',
      description: 'Run full system file check',
      sudo: true,
      dangerous: true
    }
  }

  OPTIMIZATION_COMMANDS = {
    clear_system_cache: {
      command: 'sudo purge',
      description: 'Clear system memory cache',
      sudo: true
    },
    reindex_mail: {
      command: 'rm -rf ~/Library/Mail/V*/MailData/Envelope\ Index && killall Mail',
      description: 'Reindex Apple Mail database',
      sudo: false
    },
    disable_animations: {
      command: <<~BASH,
        defaults write com.apple.finder DisableAllAnimations -bool true
        defaults write com.apple.dock launchanim -bool false
        defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
        killall Finder
        killall Dock
      BASH
      description: 'Disable system animations for performance',
      sudo: false
    },
    enable_animations: {
      command: <<~BASH,
        defaults delete com.apple.finder DisableAllAnimations
        defaults delete com.apple.dock launchanim
        defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled
        killall Finder
        killall Dock
      BASH
      description: 'Enable system animations',
      sudo: false
    }
  }

  def initialize
    setup_environment
    @options = {}
    @logger = setup_logger
    @config = load_config
  end

  def setup_environment
    FileUtils.mkdir_p(LOGS_DIR) unless Dir.exist?(LOGS_DIR)
    
    unless File.exist?(CONFIG_PATH)
      default_config = {
        'verbose_output' => true,
        'save_diagnostics' => true,
        'auto_clear_logs' => 30, # days
        'sudo_timeout' => 120,   # seconds
        'safe_mode' => true      # prevent dangerous operations
      }
      
      File.write(CONFIG_PATH, default_config.to_yaml)
    end
  end

  def setup_logger
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    log_file = File.join(LOGS_DIR, "troubleshoot_#{timestamp}.log")
    
    logger = Logger.new(log_file)
    logger.level = Logger::INFO
    logger.formatter = proc do |severity, datetime, _, msg|
      "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}]: #{msg}\n"
    end
    
    logger
  end

  def load_config
    YAML.load_file(CONFIG_PATH)
  rescue StandardError => e
    @logger.error("Failed to load config: #{e.message}")
    { 'verbose_output' => true, 'save_diagnostics' => true, 'safe_mode' => true }
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
      
      opts.on('-d', '--diagnose', 'Run full system diagnostics') do
        @options[:diagnose] = true
      end
      
      opts.on('-r', '--repair', 'Run common repair operations') do
        @options[:repair] = true
      end
      
      opts.on('-o', '--optimize', 'Run system optimization tasks') do
        @options[:optimize] = true
      end
      
      opts.on('-c', '--custom COMMAND', 'Run a specific diagnostic or repair command') do |cmd|
        @options[:custom] = cmd
      end
      
      opts.on('-l', '--list-commands', 'List all available commands') do
        @options[:list] = true
      end
      
      opts.on('-f', '--force', 'Allow potentially dangerous operations') do
        @options[:force] = true
      end
      
      opts.on('-v', '--verbose', 'Enable verbose output') do
        @options[:verbose] = true
      end
      
      opts.on('-q', '--quiet', 'Suppress all output except errors') do
        @options[:quiet] = true
      end
      
      opts.on('--version', 'Show version information') do
        @options[:version] = true
      end
      
      opts.on('-h', '--help', 'Show this help message') do
        @options[:help] = true
      end
    end.parse!
    
    # Default to help if no options provided
    @options[:help] = true if @options.empty?
  end

  def run
    parse_options
    
    if @options[:help]
      show_help
      return
    end
    
    if @options[:version]
      puts "MacOS Troubleshooter v#{VERSION}"
      return
    end
    
    if @options[:list]
      list_commands
      return
    end
    
    # Run selected operations
    case
    when @options[:custom]
      run_custom_command(@options[:custom])
    when @options[:diagnose]
      run_diagnostics
    when @options[:repair]
      run_repairs
    when @options[:optimize]
      run_optimizations
    else
      show_help
    end
  end

  def show_help
    puts "MacOS Troubleshooter v#{VERSION}"
    puts "A comprehensive system diagnostic and repair tool"
    puts
    puts "Usage: #{$PROGRAM_NAME} [options]"
    puts
    puts "Options:"
    puts "  -d, --diagnose              Run full system diagnostics"
    puts "  -r, --repair                Run common repair operations"
    puts "  -o, --optimize              Run system optimization tasks"
    puts "  -c, --custom COMMAND        Run a specific diagnostic or repair command"
    puts "  -l, --list-commands         List all available commands"
    puts "  -f, --force                 Allow potentially dangerous operations"
    puts "  -v, --verbose               Enable verbose output"
    puts "  -q, --quiet                 Suppress all output except errors"
    puts "      --version               Show version information"
    puts "  -h, --help                  Show this help message"
    puts
    puts "Examples:"
    puts "  #{$PROGRAM_NAME} --diagnose              # Run all diagnostics"
    puts "  #{$PROGRAM_NAME} --repair                # Run safe repair operations"
    puts "  #{$PROGRAM_NAME} --custom disk_space     # Check disk space"
    puts "  #{$PROGRAM_NAME} --custom clear_dns_cache --force # Force run a repair operation"
    puts
    puts "For a complete list of commands, use --list-commands"
  end

  def list_commands
    puts "Available diagnostic commands:"
    DIAGNOSTIC_COMMANDS.each do |key, cmd|
      puts "  #{key}: #{cmd[:description]}"
    end
    
    puts "\nAvailable repair commands:"
    REPAIR_COMMANDS.each do |key, cmd|
      dangerous = cmd[:dangerous] ? " (potentially dangerous)" : ""
      sudo = cmd[:sudo] ? " (requires sudo)" : ""
      puts "  #{key}: #{cmd[:description]}#{sudo}#{dangerous}"
    end
    
    puts "\nAvailable optimization commands:"
    OPTIMIZATION_COMMANDS.each do |key, cmd|
      sudo = cmd[:sudo] ? " (requires sudo)" : ""
      puts "  #{key}: #{cmd[:description]}#{sudo}"
    end
  end

  def run_custom_command(command_name)
    command = DIAGNOSTIC_COMMANDS[command_name.to_sym] ||
              REPAIR_COMMANDS[command_name.to_sym] ||
              OPTIMIZATION_COMMANDS[command_name.to_sym]
    
    if command.nil?
      puts "Error: Command '#{command_name}' not found. Use --list-commands to see available options."
      return
    end
    
    if command[:dangerous] && !@options[:force] && @config['safe_mode']
      puts "Warning: This command is potentially dangerous and may cause data loss or system issues."
      puts "Use --force to run anyway."
      return
    end
    
    if command[:sudo] && !@options[:force] && @config['safe_mode'] && !command_name.to_sym.to_s.start_with?('system_')
      puts "Warning: This command requires sudo privileges."
      puts "Use --force to run anyway."
      return
    end
    
    if command[:manual]
      puts "Manual instruction: #{command[:command]}"
      return
    end
    
    puts "Running: #{command[:description]}" unless @options[:quiet]
    
    start_time = Time.now
    output = execute_command(command[:command])
    end_time = Time.now
    
    puts output unless @options[:quiet]
    
    duration = end_time - start_time
    @logger.info("Ran command: #{command_name} (took #{duration.round(2)}s)")
    @logger.info("Output: #{output}") if @config['save_diagnostics']
    
    puts "Command completed in #{duration.round(2)}s" if @options[:verbose] && !@options[:quiet]
  end

  def run_diagnostics
    puts "Running full system diagnostics..." unless @options[:quiet]
    results = {}
    
    DIAGNOSTIC_COMMANDS.each do |key, cmd|
      puts "  Running: #{cmd[:description]}..." if @options[:verbose] && !@options[:quiet]
      
      start_time = Time.now
      output = execute_command(cmd[:command])
      end_time = Time.now
      
      duration = end_time - start_time
      @logger.info("Diagnostic: #{key} (took #{duration.round(2)}s)")
      @logger.info("Output: #{output}") if @config['save_diagnostics']
      
      results[key] = {
        description: cmd[:description],
        output: output,
        duration: duration.round(2)
      }
    end
    
    # Output summary
    unless @options[:quiet]
      puts "\nDiagnostic Results:"
      results.each do |key, result|
        puts "  #{result[:description]}: Completed in #{result[:duration]}s"
        
        if @options[:verbose]
          puts "  " + "=" * 40
          puts result[:output].lines.map { |line| "    #{line}" }.join
          puts "  " + "=" * 40
          puts
        end
      end
    end
    
    puts "\nFull diagnostics complete. Log saved to: #{@logger.instance_variable_get(:@logdev).filename}" unless @options[:quiet]
    
    results
  end

  def run_repairs
    puts "Running system repairs..." unless @options[:quiet]
    
    REPAIR_COMMANDS.each do |key, cmd|
      next if cmd[:dangerous] && !@options[:force] && @config['safe_mode']
      next if cmd[:sudo] && !@options[:force] && @config['safe_mode']
      next if cmd[:manual]
      
      puts "  Running: #{cmd[:description]}..." unless @options[:quiet]
      
      start_time = Time.now
      output = execute_command(cmd[:command])
      end_time = Time.now
      
      duration = end_time - start_time
      @logger.info("Repair: #{key} (took #{duration.round(2)}s)")
      @logger.info("Output: #{output}") if @config['save_diagnostics']
      
      if @options[:verbose] && !@options[:quiet]
        puts "  " + "=" * 40
        puts output.lines.map { |line| "    #{line}" }.join
        puts "  " + "=" * 40
      end
    end
    
    puts "\nSystem repairs complete. Some changes may require a restart to take effect." unless @options[:quiet]
  end

  def run_optimizations
    puts "Running system optimizations..." unless @options[:quiet]
    
    OPTIMIZATION_COMMANDS.each do |key, cmd|
      next if cmd[:sudo] && !@options[:force] && @config['safe_mode']
      
      puts "  Running: #{cmd[:description]}..." unless @options[:quiet]
      
      start_time = Time.now
      output = execute_command(cmd[:command])
      end_time = Time.now
      
      duration = end_time - start_time
      @logger.info("Optimization: #{key} (took #{duration.round(2)}s)")
      @logger.info("Output: #{output}") if @config['save_diagnostics']
      
      if @options[:verbose] && !@options[:quiet]
        puts "  " + "=" * 40
        puts output.lines.map { |line| "    #{line}" }.join
        puts "  " + "=" * 40
      end
    end
    
    puts "\nSystem optimizations complete." unless @options[:quiet]
  end

  def execute_command(command)
    output = `#{command} 2>&1`
    status = $CHILD_STATUS.exitstatus
    
    if status != 0
      @logger.warn("Command exited with status #{status}: #{command}")
    end
    
    output
  end

  def cleanup_old_logs
    return unless @config['auto_clear_logs']
    
    days = @config['auto_clear_logs'].to_i
    return if days <= 0
    
    cutoff_time = Time.now - (days * 24 * 60 * 60)
    
    Dir.glob(File.join(LOGS_DIR, "*.log")).each do |log_file|
      begin
        file_time = File.mtime(log_file)
        if file_time < cutoff_time
          File.delete(log_file)
          @logger.info("Deleted old log file: #{log_file}")
        end
      rescue StandardError => e
        @logger.error("Failed to process log file #{log_file}: #{e.message}")
      end
    end
  end
end

# Run the application
if __FILE__ == $PROGRAM_NAME
  troubleshooter = MacOSTroubleshooter.new
  troubleshooter.run
  troubleshooter.cleanup_old_logs
end
