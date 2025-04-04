# 6/7 Coding Challenge Scripts

**⚠️ NOTE: The implementation has been upgraded to use Ruby for improved reliability and cross-platform compatibility.**

This directory contains the automation scripts that power the 6/7 Coding Challenge. These scripts help maintain consistency, track progress, and simplify the daily workflow.

## Script Overview

| Script | Description |
|--------|-------------|
| `cc-installer.rb` | Main Ruby installer for installation, updates, and uninstallation |
| `cc-start-day.rb` | Initializes the environment for a new challenge day |
| `cc-log-progress.rb` | Records the day's progress in the weekly log file |
| `cc-push-updates.rb` | Commits and pushes changes, increments the day counter |
| `cc-status.rb` | Displays the current challenge status and progress |
| `cc-update.rb` | Updates scripts to the latest version |
| `cc-uninstall.rb` | Removes scripts and configuration |

## Installation

### Basic Installation

1. Clone the repository:
   ```zsh
   git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
   cd 6-7-coding-challenge
   ```

2. Install the Ruby setup script:
   ```zsh
   mkdir -p ~/bin
   cp scripts/cc-installer.rb ~/bin/
   chmod +x ~/bin/cc-installer.rb
   ```

3. Run the installer:
   ```zsh
   ruby ~/bin/cc-installer.rb
   ```

4. Source your `.zshrc` or restart your terminal:
   ```zsh
   source ~/.zshrc
   ```

### Installation Options

The Ruby installer script offers multiple modes:

```zsh
# Standard installation (detects existing installation)
ruby ~/bin/cc-installer.rb

# Force reinstallation
ruby ~/bin/cc-installer.rb --install

# Update an existing installation 
ruby ~/bin/cc-installer.rb --update
# or use the alias after installation:
ccupdate

# Uninstall
ruby ~/bin/cc-installer.rb --uninstall
# or use the alias after installation:
ccuninstall

# Verbose output for troubleshooting
ruby ~/bin/cc-installer.rb --verbose
```

## Prerequisites

The scripts require these tools to be installed:

- **Ruby**: For the installer and script execution (`ruby -v`)
- **zsh**: As your shell (`echo $SHELL`)
- **git**: For version control (`git --version`)

Optional but recommended:
- **tmux**: For terminal session management (`tmux -V`)
- **neovim** or **vim**: For editing files

The installer script will check for these dependencies and provide appropriate warnings if they're missing.

## Daily Workflow

1. Start your day:
   ```zsh
   ccstart
   ```
   This opens a tmux session with your challenge environment.

2. After your coding session, log your progress:
   ```zsh
   cclog
   ```

3. Push your changes and increment the day counter:
   ```zsh
   ccpush
   ```

4. Check your overall progress:
   ```zsh
   ccstatus
   ```

## New Feature: Retroactive Logging

The enhanced `cclog` command now supports logging progress for previous days:

```zsh
# Log the current day (normal usage)
cclog

# Log a specific previous day
cclog 5  # Logs day 5 specifically
```

This is useful if you forget to log on a particular day.

## Script Details

### cc-installer.rb

**Purpose**: Unified Ruby installer for installation, updates, and uninstallation

**Features**:
- Intelligently detects existing installations
- Offers appropriate actions based on current state
- Creates directory structure for all phases
- Installs scripts to `~/bin/`
- Initializes or preserves day counter
- Sets up git repository if needed
- Creates or updates `.gitignore`
- Adds or updates aliases in `.zshrc`
- Provides comprehensive error handling
- Works across macOS, Linux, and WSL

**Usage**:
```zsh
ruby ~/bin/cc-installer.rb [--install|--update|--uninstall|--verbose|--force|--help]
```

### cc-start-day.rb

**Purpose**: Initialize the environment for a new challenge day

**Features**:
- Calculates current phase, week, and day
- Checks if it's Sunday and reminds you to rest if it is
- Creates appropriate directory structure
- Initializes a README template for the day
- Opens a tmux session with the right directory and files
- Falls back gracefully if tmux is not installed
- Platform-compatible for macOS and Linux

**Usage**:
```zsh
ccstart
```

### cc-log-progress.rb

**Purpose**: Record daily progress in weekly log files

**Features**:
- Extracts sections from README.md
- Appends them to the weekly log file
- Maintains consistent log formatting
- Creates new log files as needed
- Supports all phases of the challenge
- **NEW**: Supports retroactive logging for missed days
- Inserts entries in correct chronological order
- Handles duplicate entries appropriately

**Usage**:
```zsh
# Log current day (standard usage)
cclog

# Log a specific previous day
cclog <day_number>
```

### cc-push-updates.rb

**Purpose**: Commit changes and increment the day counter

**Features**:
- Automatically adds all changes to git
- Creates descriptive commit messages including:
  - Day number
  - Date
  - Primary goal from README
- Pushes to remote repository
- Increments day counter for tomorrow
- Provides status update after push

**Usage**:
```zsh
ccpush
```

### cc-status.rb

**Purpose**: Display challenge progress and statistics

**Features**:
- Shows current day, phase, and week
- Calculates progress percentage
- Estimates completion date based on current day
- Displays days remaining
- Shows streak information
- Includes repository status
- Colorized output for better readability
- Platform-compatible date calculations
- Schedule tracking (ahead/behind)

**Usage**:
```zsh
ccstatus
```

## Platform Compatibility

The scripts have been improved to work across different platforms:

### macOS

All scripts work natively on macOS with no additional configuration.

### Linux

The scripts use platform detection to use the appropriate commands on Linux systems.

### Windows (WSL)

The scripts work in Windows Subsystem for Linux with no modifications needed.

## Troubleshooting

The enhanced error handling will provide clear messages for most issues. Common issues and solutions:

### Installation Issues

```zsh
# Retry installation with verbose output
ruby ~/bin/cc-installer.rb --verbose
```

### Script Issues

```zsh
# Update to the latest version
ccupdate
```

### Configuration Issues

```zsh
# Check configuration
cat ~/.cc-config

# Check day counter
cat ~/.cc-current-day
```

### Directory Structure Issues

```zsh
# Verify directory structure
ls -la ~/projects/6-7-coding-challenge
```

Last updated: April 2025
