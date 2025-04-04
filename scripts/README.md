# 6/7 Coding Challenge Scripts

**⚠️ DISCLAIMER: This is a work in progress. I am still working out bugs and refining the configuration. Use at your own risk and please report any issues you encounter.**

This directory contains the automation scripts that power the 6/7 Coding Challenge. These scripts help maintain consistency, track progress, and simplify the daily workflow.

## Script Overview

| Script | Description |
|--------|-------------|
| `cc-setup.sh` | Unified script for installation, updates, and uninstallation |
| `cc-start-day.sh` | Initializes the environment for a new challenge day |
| `cc-log-progress.sh` | Records the day's progress in the weekly log file |
| `cc-push-updates.sh` | Commits and pushes changes, increments the day counter |
| `cc-status.sh` | Displays the current challenge status and progress |
| `cc-update.sh` | Updates scripts to the latest version |
| `cc-uninstall.sh` | Removes scripts and configuration |

## Installation

### Basic Installation

1. Clone the repository:
   ```zsh
   git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
   cd 6-7-coding-challenge
   ```

2. Run the setup script:
   ```zsh
   zsh scripts/cc-setup.sh
   ```

3. Source your `.zshrc` or restart your terminal:
   ```zsh
   source ~/.zshrc
   ```

### Installation Options

The setup script now intelligently detects existing installations and offers appropriate actions:

```zsh
# Standard installation (detects existing installation)
zsh scripts/cc-setup.sh

# Force reinstallation
zsh scripts/cc-setup.sh --install

# Update an existing installation 
zsh scripts/cc-setup.sh --update
# or use the alias after installation:
ccupdate

# Uninstall
zsh scripts/cc-setup.sh --uninstall
# or use the alias after installation:
ccuninstall

# Show help
zsh scripts/cc-setup.sh --help
```

## Prerequisites

The scripts require these tools to be installed:

- **zsh**: As your shell (`echo $SHELL`)
- **git**: For version control (`git --version`)

Optional but recommended:
- **tmux**: For terminal session management (`tmux -V`)
- **neovim** or **vim**: For editing files
- **Ruby**: For Phase 1 projects (`ruby -v`)

The setup script will check for these dependencies and provide appropriate warnings if they're missing.

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

## New Feature: Safe Updates

You can update your scripts to the latest version at any time:

```zsh
ccupdate
```

This will:
- Backup existing scripts
- Install the latest versions
- Preserve your day counter and progress
- Update configuration files

## New Feature: Clean Uninstallation

You can completely remove the 6/7 Coding Challenge installation:

```zsh
ccuninstall
```

This will:
- Remove all scripts from ~/bin
- Clean up aliases from .zshrc
- Optionally remove the day counter
- Optionally remove all project files and logs

## Script Details

### cc-setup.sh

**Purpose**: Unified script for installation, updates, and uninstallation

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
zsh scripts/cc-setup.sh [--install|--update|--uninstall|--help]
```

### cc-start-day.sh

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

### cc-log-progress.sh

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

### cc-push-updates.sh

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

### cc-status.sh

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

### cc-update.sh (New)

**Purpose**: Update scripts to the latest version

**Features**:
- Runs the setup script in update mode
- Preserves day counter and progress
- Backs up existing scripts
- Updates configuration files
- Provides clear status messages

**Usage**:
```zsh
ccupdate
```

### cc-uninstall.sh (New)

**Purpose**: Remove scripts and configuration

**Features**:
- Removes all scripts from ~/bin
- Cleans up aliases from .zshrc
- Optionally removes the day counter
- Optionally removes all project files and logs
- Provides clear status messages

**Usage**:
```zsh
ccuninstall
```

## Platform Compatibility

The scripts have been improved to work across different platforms:

### macOS

All scripts work natively on macOS with no additional configuration.

### Linux

The scripts use platform detection to use the appropriate commands on Linux:

```zsh
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS specific commands
else
  # Linux specific commands
fi
```

### Windows (WSL)

The scripts work in Windows Subsystem for Linux with no modifications needed.

## Troubleshooting

The enhanced error handling will provide clear messages for most issues. Common issues and solutions:

### Installation Issues

```zsh
# Retry installation with verbose output
zsh -x scripts/cc-setup.sh
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

## Version Information

The scripts are now versioned, with the current version stored in the config file:

```zsh
# Check current version
grep "version=" ~/.cc-config
```

Last updated: April 2025
