# 6/7 Coding Challenge Scripts

This directory contains the Ruby installer that powers the 6/7 Coding Challenge. The installer generates all required scripts for the challenge workflow.

## Script Overview

| Script | Description |
|--------|-------------|
| `cc-installer.rb` | Main Ruby installer that generates all other scripts |

## Installation

1. Clone the repository:
   ```zsh
   git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
   cd 6-7-coding-challenge
   ```

2. Install the Ruby installer script:
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

## Maintenance

To update or modify any scripts:

1. Edit the script-generating methods in `cc-installer.rb`
2. Run the installer to regenerate all scripts:
   ```zsh
   ruby ~/bin/cc-installer.rb --update
   ```

This approach centralizes all maintenance to a single file while still benefiting from the improved reliability of Ruby scripts.

## Generated Scripts

The installer creates the following scripts in your `~/bin` directory:

| Script | Description |
|--------|-------------|
| `cc-start-day.rb` | Initializes the environment for a new challenge day |
| `cc-log-progress.rb` | Records the day's progress in the weekly log file |
| `cc-push-updates.rb` | Commits and pushes changes, increments the day counter |
| `cc-status.rb` | Displays the current challenge status and progress |
| `cc-update.rb` | Updates scripts to the latest version |
| `cc-uninstall.rb` | Removes scripts and configuration |

## Daily Workflow

After installation, use these commands:

1. `ccstart` - Start your day's coding session
2. `cclog` - Log your progress
3. `ccpush` - Commit changes and increment day counter
4. `ccstatus` - Check your overall progress

## Retroactive Logging

The scripts support logging for previous days:

```zsh
# Log a specific previous day
cclog 5  # Logs day 5 specifically
```

This centralized approach simplifies maintenance while preserving all the functionality needed for your 500-day coding journey.
