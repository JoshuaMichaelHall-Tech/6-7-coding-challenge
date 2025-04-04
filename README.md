# 6/7 Coding Challenge Scripts

This directory contains the automation scripts that power the 6/7 Coding Challenge. These scripts help maintain consistency, track progress, and simplify the daily workflow.

## Script Overview

| Script | Description |
|--------|-------------|
| `cc-setup.sh` | One-time setup script for the challenge environment |
| `cc-start-day.sh` | Initializes the environment for a new challenge day |
| `cc-log-progress.sh` | Records the day's progress in the weekly log file |
| `cc-push-updates.sh` | Commits and pushes changes, increments the day counter |
| `cc-status.sh` | Displays the current challenge status and progress |

## Installation

1. Clone the repository:
   ```zsh
   git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
   cd 6-7-coding-challenge
   ```

2. Run the setup script:
   ```zsh
   zsh scripts/cc-setup.sh
   ```

   This will:
   - Create necessary directories in `~/projects/6-7-coding-challenge/`
   - Install scripts to `~/bin/`
   - Initialize the day counter
   - Add aliases to your `.zshrc`
   - Set up git repository with .gitignore

3. Source your `.zshrc` or restart your terminal:
   ```zsh
   source ~/.zshrc
   ```

## Prerequisites

The scripts require these tools to be installed:

- **zsh**: As your shell (`echo $SHELL`)
- **git**: For version control (`git --version`)
- **tmux**: For terminal session management (`tmux -V`)

Optional but recommended:
- **neovim**: For editing files (`nvim --version`)
- **Ruby**: For Phase 1 projects (`ruby -v`)

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

## Script Details

### cc-setup.sh

**Purpose**: One-time setup for the challenge environment

**Features**:
- Creates directory structure for all phases
- Installs scripts to `~/bin/`
- Initializes day counter
- Sets up git repository
- Creates default `.gitignore`
- Adds aliases to `.zshrc`

**Usage**:
```zsh
zsh scripts/cc-setup.sh
```

**Error Handling**:
- Checks for required tools (git, tmux)
- Verifies successful directory creation
- Validates script permissions
- Reports specific errors for troubleshooting

### cc-start-day.sh

**Purpose**: Initialize the environment for a new challenge day

**Features**:
- Calculates current phase, week, and day
- Checks if it's Sunday and reminds you to rest if it is
- Creates appropriate directory structure
- Initializes a README template for the day
- Opens a tmux session with the right directory and files
- Platform-compatible for macOS and Linux

**Usage**:
```zsh
ccstart
```

**Error Handling**:
- Verifies day counter exists
- Checks if tmux is installed
- Validates directory creation
- Handles existing tmux sessions

**tmux Session Layout**:
- Top pane: Terminal in the day's project directory
- Bottom pane: Editor with README.md open

### cc-log-progress.sh

**Purpose**: Record daily progress in weekly log files

**Features**:
- Extracts sections from README.md
- Appends them to the weekly log file
- Maintains consistent log formatting
- Creates new log files as needed
- Supports all phases of the challenge
- **NEW**: Supports retroactive logging for missed days

**Usage**:
```zsh
# Log current day (standard usage)
cclog

# Log a specific previous day
cclog <day_number>
```

**Error Handling**:
- Validates existence of README.md
- Checks write permissions for log file
- Reports detailed errors for each operation
- Confirms successful logging
- Handles duplicate entries when retroactively logging

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

**Error Handling**:
- Checks if there are changes to commit
- Validates git repository status
- Confirms remote repository exists
- Verifies day counter update

**Commit Message Format**:
```
Day X: YYYY-MM-DD - Primary goal description
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

**Output Example**:
```
╔═══════════════════════════════════════════════════╗
║            6/7 CODING CHALLENGE STATUS             ║
╠═══════════════════════════════════════════════════╣
║ Current Day: 42/500                               ║
║ Phase: 1 of 5 - Ruby Backend                      ║
║ Week: 7 overall (Week 7 in Phase 1)               ║
║ Day of Week: 6/6                                  ║
║ Progress: 8% complete                             ║
║ Days Elapsed: 41                                  ║
║ Schedule Status: On schedule                      ║
║ Days Remaining: 459                               ║
║ Estimated Completion: 2026-07-04                  ║
║ Current Streak: 6 day(s)                          ║
╠═══════════════════════════════════════════════════╣
║ Active Branch: main                               ║
║ Last Commit: a1b2c3d - Day 41: 2025-05-12        ║
║ Commit Date: 2025-05-12                           ║
╚═══════════════════════════════════════════════════╝
```

## Retroactive Logging Feature

The enhanced `cclog` command now supports logging progress for previous days, which is useful if you forget to log on a particular day. See [Log Command Enhancement Documentation](../docs/cc-log-enhancement-docs.md) for detailed information.

### Basic Usage:

```zsh
# Log the current day (normal usage)
cclog

# Log a specific previous day
cclog 5  # Logs day 5 specifically
```

This feature maintains chronological ordering in your log files and handles duplicate entries appropriately.

## Custom Modifications

You can modify these scripts to better suit your workflow. Here are common customization points:

### README Template

To customize the README template, edit `cc-start-day.sh`:

```zsh
# Find this section in cc-start-day.sh
cat > $PROJECT_DIR/README.md << EOF
# Day $CURRENT_DAY - Phase $PHASE (Week $WEEK_FORMATTED)

## Today's Focus
...
EOF
```

### tmux Layout

To change the tmux window layout, modify this section in `cc-start-day.sh`:

```zsh
# Configure the windows
tmux split-window -v -p 30 -t coding-challenge

# For horizontal split instead:
# tmux split-window -h -p 50 -t coding-challenge

# For additional panes:
# tmux split-window -v -p 30 -t coding-challenge:0.1
```

### Status Display

To adjust the status display, edit `cc-status.sh`:

```zsh
# Modify the status display format
printf "${BOLD}║${RESET} ${GREEN}Current Day:${RESET} %-37s ${BOLD}║${RESET}\n" "$CURRENT_DAY/500"

# Add additional metrics
printf "${BOLD}║${RESET} ${CYAN}Custom Metric:${RESET} %-34s ${BOLD}║${RESET}\n" "Your value here"
```

### Day Counter

To reset or adjust your day counter:

```zsh
# Reset to day 1
echo "1" > ~/.cc-current-day

# Jump to a specific day
echo "42" > ~/.cc-current-day
```

## Platform Compatibility

The scripts have been improved to work across different platforms:

### macOS

All scripts work natively on macOS with no additional configuration.

### Linux

The scripts use platform detection to use the appropriate date commands on Linux:

```zsh
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS date commands
  COMPLETION_DATE=$(date -v+${DAYS_REMAINING}d +"%Y-%m-%d")
else
  # Linux date commands
  COMPLETION_DATE=$(date -d "+${DAYS_REMAINING} days" +"%Y-%m-%d")
fi
```

### Windows (WSL)

The scripts work in Windows Subsystem for Linux with no modifications needed.

## Troubleshooting

If you encounter issues:

### Script Not Found

```zsh
# Check if scripts are in ~/bin
ls -la ~/bin

# Check if ~/bin is in your PATH
echo $PATH | grep "$HOME/bin"

# Add to PATH if needed
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Permission Denied

```zsh
# Make scripts executable
chmod +x ~/bin/cc-*.sh
```

### Day Counter Issues

```zsh
# Check day counter value
cat ~/.cc-current-day

# Reset if corrupted
echo "1" > ~/.cc-current-day
```

### tmux Errors

```zsh
# Check if tmux is installed
which tmux

# Install if needed
# macOS: brew install tmux
# Ubuntu/Debian: sudo apt install tmux
# Fedora/RHEL: sudo dnf install tmux

# Kill stuck sessions
tmux kill-session -t coding-challenge
```

### Directory Structure Issues

```zsh
# Verify directory structure
ls -la ~/projects/6-7-coding-challenge

# Create if missing
mkdir -p ~/projects/6-7-coding-challenge/{logs,phase1_ruby,phase2_python,phase3_javascript,phase4_fullstack,phase5_ml_finance}
```

## Advanced Usage

### Adding Custom Scripts

You can create additional scripts to enhance your workflow:

```zsh
# Example: Weekly summary generator
cat > ~/bin/cc-weekly-summary.sh << 'EOF'
#!/bin/zsh

# Get current week
CURRENT_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)
WEEK_OVERALL=$(( ($CURRENT_DAY-1) / 6 + 1 ))

# Generate summary
echo "Generating summary for Week $WEEK_OVERALL..."
# Add your summary generation code here

EOF

chmod +x ~/bin/cc-weekly-summary.sh
```

### Debugging Scripts

To troubleshoot issues, run scripts in debug mode:

```zsh
zsh -x ~/bin/cc-start-day.sh
```

This will show each command as it executes, helping identify issues.

### Backup and Restore

To backup your challenge progress:

```zsh
# Backup day counter
cp ~/.cc-current-day ~/cc-day-backup

# Backup entire repository
cd ~/projects/6-7-coding-challenge
git bundle create ~/challenge-backup.bundle --all
```

To restore:

```zsh
# Restore day counter
cp ~/cc-day-backup ~/.cc-current-day

# Restore repository
git clone ~/challenge-backup.bundle ~/projects/6-7-coding-challenge-restored
```

## Version Information

All scripts have been updated with:
- Improved error handling
- Platform compatibility
- Enhanced feedback
- Better performance
- Consistent formatting
- Retroactive logging support

Last updated: April 2025
