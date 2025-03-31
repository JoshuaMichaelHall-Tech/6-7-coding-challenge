# 6/7 Coding Challenge Scripts

This directory contains the automation scripts that power the 6/7 Coding Challenge. These scripts help maintain consistency, track progress, and simplify the daily workflow.

## Script Overview

| Script | Description |
|--------|-------------|
| `cc-start-day.sh` | Initializes the environment for a new challenge day |
| `cc-log-progress.sh` | Records the day's progress in the weekly log file |
| `cc-push-updates.sh` | Commits and pushes changes, increments the day counter |
| `cc-status.sh` | Displays the current challenge status and progress |
| `cc-setup.sh` | One-time setup script for the challenge environment |

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

3. Add these aliases to your `.zshrc`:
   ```zsh
   # 6/7 Coding Challenge aliases
   alias ccstart="~/bin/cc-start-day.sh"
   alias cclog="~/bin/cc-log-progress.sh"
   alias ccpush="~/bin/cc-push-updates.sh"
   alias ccstatus="~/bin/cc-status.sh"
   ```

4. Source your `.zshrc` or restart your terminal:
   ```zsh
   source ~/.zshrc
   ```

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

### cc-start-day.sh

This script:
- Calculates the current phase, week, and day
- Checks if it's Sunday and reminds you to rest if it is
- Creates the appropriate directory structure
- Initializes a README template for the day
- Opens a tmux session with the right directory and files

### cc-log-progress.sh

This script:
- Extracts the progress and reflections from your day's README
- Appends them to the weekly log file
- Formats the content appropriately

### cc-push-updates.sh

This script:
- Adds all changes to git
- Commits with a standardized commit message
- Pushes to the remote repository
- Increments the day counter for tomorrow

### cc-status.sh

This script:
- Shows your current day, phase, and week
- Calculates your overall progress percentage
- Estimates your completion date
- Displays days remaining

### Custom Modifications

Feel free to modify these scripts to better suit your workflow. Some common modifications include:

- Changing the tmux layout in `cc-start-day.sh`
- Modifying the README template in `cc-start-day.sh`
- Customizing the commit message format in `cc-push-updates.sh`
- Adding additional statistics to `cc-status.sh`

## Troubleshooting

If you encounter issues:

1. Check script permissions:
   ```zsh
   ls -la ~/bin
   ```

2. Ensure day counter exists:
   ```zsh
   cat ~/.cc-current-day
   ```

3. Verify directory structure:
   ```zsh
   ls -la ~/projects/6-7-coding-challenge
   ```

4. Check for tmux installation:
   ```zsh
   which tmux
   ```
