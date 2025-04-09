# 6/7 Coding Challenge Customization Guide

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