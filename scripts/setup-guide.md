# 6/7 Coding Challenge Setup Guide

This guide will help you set up the Ruby-based scripts for your 6/7 Coding Challenge. These scripts provide a streamlined workflow for your 500-day coding journey.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
cd 6-7-coding-challenge

# Make all Ruby scripts executable
chmod +x scripts/*.rb

# Create a ~/bin directory if it doesn't exist
mkdir -p ~/bin

# Copy the installer script to your bin directory
cp scripts/cc-installer.rb ~/bin/
chmod +x ~/bin/cc-installer.rb

# Run the installer
ruby ~/bin/cc-installer.rb

# Source your .zshrc or restart your terminal
source ~/.zshrc

# Start your first day
ccstart
```

## What the Scripts Do

The 6/7 Coding Challenge infrastructure consists of several Ruby scripts that work together:

1. **cc-installer.rb**: Main installer that sets up the environment
2. **cc-start-day.rb**: Initializes each day's coding environment
3. **cc-log-progress.rb**: Records your progress in weekly logs
4. **cc-push-updates.rb**: Commits changes and increments the day counter
5. **cc-status.rb**: Shows your current progress and statistics
6. **cc-update.rb**: Updates scripts to the latest version
7. **cc-uninstall.rb**: Removes the challenge infrastructure

## Daily Workflow

After installation, your typical workflow will be:

1. **Start your day**: Run `ccstart` to initialize the environment for the current day
   - Creates appropriate directory structure
   - Prepares README template
   - Opens a tmux session with your editor

2. **Work on your challenge**: Code and document your progress in the README

3. **Log your progress**: Run `cclog` to extract information from your README and add it to your weekly log

4. **Commit and push**: Run `ccpush` to commit your changes, push to the repository, and increment the day counter

5. **Check your progress**: Run `ccstatus` at any time to see your overall challenge progress

## Retroactive Logging

If you forget to log your progress on a particular day, you can log it retroactively:

```bash
# Log a specific previous day
cclog 5  # Logs day 5 specifically
```

This keeps your logs complete even if your workflow gets interrupted.

## Installation Options

The installer supports various options:

```bash
# Show help
ruby ~/bin/cc-installer.rb --help

# Force fresh installation
ruby ~/bin/cc-installer.rb --install

# Update scripts
ruby ~/bin/cc-installer.rb --update
# or use the shortcut after installation:
ccupdate

# Uninstall everything
ruby ~/bin/cc-installer.rb --uninstall
# or use the shortcut:
ccuninstall

# Verbose output
ruby ~/bin/cc-installer.rb --verbose
```

## Platform Compatibility

These Ruby scripts work on:
- macOS
- Linux
- Windows with WSL (Windows Subsystem for Linux)

## Troubleshooting

### Path Issues

If you get "command not found" errors:

```bash
# Check if ~/bin is in your PATH
echo $PATH | grep "$HOME/bin"

# If not, add it manually
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Permission Issues

If scripts aren't executable:

```bash
# Make all scripts executable
chmod +x ~/bin/cc-*.rb
```

### Day Counter Issues

If your day counter gets corrupted:

```bash
# Set to a specific day
echo "5" > ~/.cc-current-day  # Replace 5 with your current day
```

### Script Updates

If you modify any scripts and want to apply changes:

```bash
# Option 1: Run the updater
ccupdate

# Option 2: Run the installer with update flag
ruby ~/bin/cc-installer.rb --update
```

## Customization

You can customize how these scripts work by modifying the Ruby files directly. The key files are stored in your `~/bin` directory.

To customize the README template or any other aspect, you can edit the corresponding Ruby script. Just remember to run `ccupdate` after making changes.

---

For more detailed information about the 6/7 Coding Challenge philosophy and structure, see the [ABOUT.md](ABOUT.md) file in the repository.

Happy coding on your 500-day journey!
