# 6/7 Coding Challenge Customization Guide
Part of the [6/7 Coding Challenge](https://github.com/JoshuaMichaelHall-Tech/6-7-coding-challenge) documentation. See [Documentation Index](https://github.com/JoshuaMichaelHall-Tech/6-7-coding-challenge/blob/main/DOCUMENTATION.md) for all guides.

This guide explains how to customize the 6/7 Coding Challenge to fit your personal preferences, workflow, and learning goals.

## Configuration System

The 6/7 Coding Challenge uses a configuration file at `~/.cc-config.json` to store your preferences. This file is created during installation but can be modified at any time using the `ccconfig` command.

### Configuration File Structure

```json
{
  "version": "3.0.0",
  "user": {
    "name": "Your Name",
    "github_username": "yourusername",
    "github_email": "your@email.com"
  },
  "paths": {
    "base_dir": "/path/to/your/project",
    "bin_dir": "/path/to/your/bin"
  },
  "preferences": {
    "editor": "vim",
    "use_tmux": true,
    "auto_push": true,
    "display_colors": true
  },
  "installation": {
    "install_date": "2025-04-07",
    "last_updated": "2025-04-07"
  },
  "challenge": {
    "phases": {
      "1": { "name": "Ruby Backend", "dir": "phase1_ruby" },
      "2": { "name": "Python Data Analysis", "dir": "phase2_python" },
      "3": { "name": "JavaScript Frontend", "dir": "phase3_javascript" },
      "4": { "name": "Full-Stack Projects", "dir": "phase4_fullstack" },
      "5": { "name": "ML Finance Applications", "dir": "phase5_ml_finance" }
    },
    "days_per_week": 6,
    "days_per_phase": 100,
    "total_days": 500
  }
}
```

## Managing Your Configuration

### Command Line Interface

The `ccconfig` command provides easy access to view and modify your configuration:

```bash
# View your current configuration
ccconfig

# Set a specific option
ccconfig --set user.name="Your Name"
ccconfig --set paths.base_dir=~/my-custom-location
ccconfig --set preferences.editor=code

# Update interactively (recommended for beginners)
ccconfig --interactive

# Reset to defaults
ccconfig --reset
```

### Configuration Options Explained

#### User Information

- `user.name`: Your display name (used in commit messages)
- `user.github_username`: Your GitHub username for repository setup
- `user.github_email`: Email address for Git commits

#### File Paths

- `paths.base_dir`: Main directory for the challenge projects
- `paths.bin_dir`: Directory for CLI scripts

#### Preferences

- `preferences.editor`: Your preferred text editor
- `preferences.use_tmux`: Whether to use tmux for coding sessions
- `preferences.auto_push`: Automatically push changes to GitHub
- `preferences.display_colors`: Show colorized terminal output

#### Challenge Structure

- `challenge.days_per_week`: Number of coding days per week
- `challenge.days_per_phase`: Number of days per phase
- `challenge.total_days`: Total days for the full challenge
- `challenge.phases`: Configuration for each phase

## Common Customization Scenarios

### Using a Different Project Location

If you want to store your challenge files in a different location:

```bash
# Update the base directory
ccconfig --set paths.base_dir=~/code/my-coding-challenge

# The change will take effect with your next ccstart
```

### Using a Different Editor

To use a different code editor than the auto-detected one:

```bash
# For Visual Studio Code
ccconfig --set preferences.editor=code

# For Sublime Text
ccconfig --set preferences.editor="subl"

# For Emacs
ccconfig --set preferences.editor=emacs
```

### Changing GitHub Settings

To update your GitHub information:

```bash
# Set your GitHub username
ccconfig --set user.github_username=yourusername

# Set your commit email
ccconfig --set user.github_email=your@email.com
```

### Disabling Tmux

If you prefer to work without tmux:

```bash
ccconfig --set preferences.use_tmux=false
```

### Customizing the Challenge Structure

You can modify the challenge structure, though this is recommended only before starting or when creating a new challenge:

```bash
# Change to 5 days per week instead of 6
ccconfig --set challenge.days_per_week=5

# Use 50 days per phase instead of 100
ccconfig --set challenge.days_per_phase=50
ccconfig --set challenge.total_days=250

# Rename a phase
ccconfig --set "challenge.phases.1.name=Go Backend"
ccconfig --set "challenge.phases.1.dir=phase1_go"
```

## Data Management

The 6/7 Coding Challenge includes robust data management features to help you maintain your progress across different computers or system reinstallations.

### Log Backup Options

You can back up your logs in three different ways:

1. **Local Backup**: Saves your logs to a timestamped directory in your home folder
2. **Git Repository**: Creates a special branch in your git repository with your logs
3. **Custom Location**: Allows you to specify any directory for your backup

### Using Backup Commands

```zsh
# Backup logs using the alias
ccbackup

# Or using the installer directly
ruby ~/bin/cc-installer.rb --backup-logs
```

When you run the backup command, you'll be prompted to choose your backup method:

```
Backing Up Log Files
===================

Where would you like to backup your logs?
1) Local backup (in your home directory)
2) To the git repository
3) Custom location

Enter your choice (1-3):
```

### Backup Details

#### Local Backup

When choosing local backup, your logs will be saved to:
```
~/cc-logs-backup-YYYYMMDDHHMMSS/
```

This directory will contain:
- All your weekly log files, organized by phase
- A `backup-info.json` file with metadata about the backup
- A `restore.rb` script for easy restoration

#### Git Repository Backup

When choosing git repository backup:
- A new branch named `logs-backup-YYYYMMDDHHMMSS` will be created
- Your logs will be committed to this branch
- Your original branch will be restored after the backup
- You'll be given the option to push the backup branch to your remote repository

#### Custom Location Backup

When choosing a custom location, you'll be prompted to enter the full path where you want to store your backup.

### Restore Options

You can restore your logs from any of the backup methods:

1. **Local Backup**: Restore from a previously created local backup
2. **Git Repository**: Restore from a backup branch in your git repository
3. **Custom Location**: Restore from any directory containing a backup

### Using Restore Commands

```zsh
# Restore logs using the alias
ccrestore

# Or using the installer directly
ruby ~/bin/cc-installer.rb --restore-logs
```

When you run the restore command, you'll be prompted to choose your restore method:

```
Restoring Log Files
==================

Where would you like to restore logs from?
1) Local backup
2) From git repository
3) Custom location

Enter your choice (1-3):
```

### Restore Details

#### Local Backup Restore

When choosing to restore from a local backup:
1. You'll see a list of available backups with their timestamps
2. The current day number from each backup will be displayed if available
3. You'll be asked to confirm before existing logs are overwritten
4. You'll have the option to update your day counter to match the backup

#### Git Repository Restore

When choosing to restore from a git repository:
1. You'll see a list of available backup branches
2. The selected branch will be temporarily checked out
3. Logs will be copied from the branch to your logs directory
4. Your original branch will be restored afterward

#### Custom Location Restore

When choosing to restore from a custom location:
1. You'll be prompted to enter the full path to the backup directory
2. Logs will be copied from that location to your logs directory
3. You'll have the option to update your day counter to match the backup

### Synchronizing Between Computers

The backup and restore features are particularly useful when you need to:

1. **Switch Computers**: Back up from one computer and restore on another
2. **Reinstall Your System**: Back up before reinstallation and restore afterward
3. **Collaborate**: Share progress with others (though the challenge is designed for individual use)

### Best Practices

- **Regular Backups**: Create a backup at least weekly
- **Git Repository**: For maximum safety, use git repository backups and push to a remote
- **Verify Restores**: After restoring, run `ccstatus` to verify your progress is correctly restored
- **Day Counter**: Always choose to update your day counter when restoring to maintain consistency

### Configuring Separate Log Repositories

For advanced users, you can configure a separate repository for logs during installation:

```zsh
ccconfig --set "paths.log_repo=username/logs-repo"
ccconfig --set "paths.log_repo_type=github"
ccconfig --set "paths.log_dir=/path/to/local/logs"
```

This allows you to:
- Keep logs in a separate git repository from your code
- Share logs across multiple computers more easily
- Maintain logs even if you reset or change your main repository

## Advanced Customizations

### Customizing Templates

You can customize the daily README template by editing the `cc-start-day.rb` script:

1. Open the script in your editor:
   ```bash
   vim ~/bin/cc-start-day.rb
   ```

2. Locate the README template section and modify it to your preferences
3. Run `ccupdate` to apply your changes

### Using Different Git Services

The challenge can work with any Git service, not just GitHub:

1. Set up your repository on your preferred service (GitLab, Bitbucket, etc.)
2. In your project directory, run:
   ```bash
   git remote add origin your-git-url
   ```

### Creating a Custom Phase Structure

You can completely redefine your challenge phases:

1. Run `ccconfig --interactive`
2. When prompted "Modify challenge structure?", answer "yes"
3. Follow the prompts to customize each phase

Or, edit the configuration directly:

```bash
ccconfig --set 'challenge.phases={"1":{"name":"Web Fundamentals","dir":"phase1_web"},"2":{"name":"Mobile Development","dir":"phase2_mobile"},"3":{"name":"Cloud Infrastructure","dir":"phase3_cloud"}}'
```

## Sharing Your Customized Challenge

If you've created a customized version of the challenge that others might benefit from:

1. Fork the original repository on GitHub
2. Make your customizations
3. Update the documentation to reflect your changes
4. Consider creating a pull request to contribute back to the main project

## Troubleshooting

### Configuration Not Applying

If your configuration changes don't seem to be taking effect:

1. Verify your configuration file:
   ```bash
   cat ~/.cc-config.json
   ```

2. Make sure the format is valid JSON
3. Run `ccconfig` to see what the system is reading
4. Try resetting to defaults with `ccconfig --reset` and then reconfigure

### Fixing Incorrect Paths

If you've set incorrect paths and scripts are failing:

```bash
# Reset just the paths section
ccconfig --set 'paths={"base_dir":"~/projects/6-7-coding-challenge","bin_dir":"~/bin"}'
```

## Creating a Completely Different Challenge

You can use this infrastructure to create an entirely different type of challenge:

1. Fork the repository
2. Modify the configuration structure in `lib/cc_config.rb` to include your custom parameters
3. Update the scripts to handle your new structure
4. Create new documentation explaining your challenge

---

Remember that the flexibility of this system allows you to tailor your learning journey to your specific goals, schedule, and preferences. By customizing the challenge, you make it your own and increase the likelihood of following through on this long-term commitment.