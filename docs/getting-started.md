# Getting Started with the 6/7 Coding Challenge

Welcome to the 6/7 Coding Challenge! This comprehensive guide will help you set up your environment and begin your 500-day journey toward software engineering mastery through consistent practice while honoring the Sabbath.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Core Commands](#core-commands)
- [Daily Workflow](#daily-workflow)
- [Understanding the Directory Structure](#understanding-the-directory-structure)
- [Customization Options](#customization-options)
- [Troubleshooting](#troubleshooting)
- [Platform Compatibility](#platform-compatibility)

## Prerequisites

Before starting the challenge, ensure you have:

- **Ruby**: Required for the installer and scripts (`ruby -v`)
- **Git**: For version control (`git --version`)
- **zsh**: As your shell (`echo $SHELL`)
- **tmux**: For terminal session management (`tmux -V`) - recommended but optional
- **Neovim** or **vim**: Recommended editors (`nvim --version` or `vim --version`)

## Installation

### Step 1: Clone the Repository

```zsh
git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
cd 6-7-coding-challenge
```

### Step 2: Install the Ruby Installer Script

```zsh
mkdir -p ~/bin
cp scripts/cc-installer.rb ~/bin/
chmod +x ~/bin/cc-installer.rb
```

### Step 3: Run the Installer

```zsh
ruby ~/bin/cc-installer.rb
```

The installer will:
- Check for prerequisites
- Create necessary directories
- Install challenge scripts in `~/bin`
- Initialize the day counter
- Set up git repository with .gitignore
- Add aliases to your .zshrc

### Step 4: Source Your .zshrc or Restart Your Terminal

```zsh
source ~/.zshrc
```

### Step 5: Start Your First Day

```zsh
ccstart
```

This will open a tmux session with the appropriate files for your first day.

## Core Commands

These commands will be available after installation:

| Command    | Description                                           |
|------------|-------------------------------------------------------|
| `ccstart`  | Start the day's coding session in tmux                |
| `cclog`    | Record your progress in the weekly log                |
| `ccpush`   | Commit changes and increment the day counter          |
| `ccstatus` | Show your overall challenge progress                  |
| `ccconfig` | View or modify your configuration                     |
| `ccupdate` | Update scripts to the latest version                  |
| `ccuninstall` | Remove scripts and configuration                   |

## Daily Workflow

1. **Start your day** with `ccstart`
   - Checks if it's a Sabbath (Sunday)
   - Creates the appropriate directory structure
   - Initializes a README template
   - Opens a tmux session in the right location

2. **Work on your daily challenge goals**
   - Fill in the README with your goals and progress
   - Complete your coding for the day

3. **Log your progress** with `cclog`
   - Extracts information from your README
   - Appends it to the weekly log file

4. **Commit and push your work** with `ccpush`
   - Commits all changes with a standardized message
   - Pushes to the remote repository
   - Increments the day counter for tomorrow

5. **Check your progress** with `ccstatus`
   - Shows your current day, phase, and week
   - Calculates your progress percentage
   - Estimates your completion date
   - Shows git streak information

## Understanding the Directory Structure

The 6/7 Coding Challenge creates this directory structure:

```
~/projects/6-7-coding-challenge/
├── phase1_python/          # Phase 1 project directories
│   ├── week01/
│   │   ├── day1/
│   │   │   └── README.md   # Daily project documentation
│   │   ├── day2/
│   │   └── ...
│   ├── week02/
│   └── ...
├── logs/                   # Log files organized by phase
│   ├── phase1/
│   │   ├── week01.md       # Weekly progress logs
│   │   ├── week02.md
│   │   └── ...
└── ...
```

## Customization Options

You can view and modify your configuration with:

```zsh
# View current configuration
ccconfig

# Update configuration interactively
ccconfig --interactive

# Set a specific configuration value
ccconfig --set user.github_username=yourusername
ccconfig --set preferences.editor=vim
```

### Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `user.name` | Your name | System username |
| `user.github_username` | GitHub username | (empty) |
| `user.github_email` | Email for git commits | (empty) |
| `paths.base_dir` | Project directory | `~/projects/6-7-coding-challenge` |
| `paths.bin_dir` | Scripts directory | `~/bin` |
| `preferences.editor` | Preferred text editor | (auto-detected) |
| `preferences.use_tmux` | Whether to use tmux | `true` if installed |
| `preferences.auto_push` | Auto-push to GitHub | `true` |
| `preferences.display_colors` | Show colorized output | `true` |

## Retroactive Logging

If you forget to log on a particular day, you can log it retroactively:

```zsh
# Log the current day (normal usage)
cclog

# Log a specific previous day
cclog 5  # Logs day 5 specifically
```

## Template Files

### Daily README Template

When you run `ccstart`, it creates a README.md template:

```markdown
# Day 1 - Phase 1 (Week 01)

## Today's Focus
- [ ] Primary goal: 
- [ ] Secondary goal: 
- [ ] Stretch goal: 

## Launch School Connection
- Current course: 
- Concept application: 

## Progress Log
- Started: 2025-04-01 09:00
- 

## Reflections
- 
```

### Weekly Log Format

Each week's log file follows this structure:

```markdown
# Week 01 (Days 1-6)

## Week Overview
- **Focus**: 
- **Launch School Connection**: 
- **Weekly Goals**:
  - 
  - 
  - 

## Daily Logs

## Day 1
...

## Day 2
...
```

## Troubleshooting

### Common Issues and Solutions

#### Script Permission Issues

```zsh
# Check permissions
ls -la ~/bin

# Fix permissions
chmod +x ~/bin/cc-*.rb
```

#### Day Counter Not Found

```zsh
# Check if file exists
cat ~/.cc-current-day

# Create or reset counter
echo "1" > ~/.cc-current-day
```

#### tmux Session Issues

```zsh
# List running sessions
tmux ls

# Kill stuck session
tmux kill-session -t coding-challenge

# Check tmux installation
which tmux
# If not installed: brew install tmux
```

#### Git Repository Issues

```zsh
# Check repository status
cd ~/projects/6-7-coding-challenge && git status

# Initialize repository if needed
git init

# Add remote
git remote add origin https://github.com/yourusername/your-repo.git
```

#### Path Issues

```zsh
# Check if bin directory is in PATH
echo $PATH | grep -q "$HOME/bin" && echo "In path" || echo "Not in path"

# Add to PATH if needed
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Troubleshooting with Verbose Mode

For detailed output when troubleshooting:

```zsh
ruby ~/bin/cc-installer.rb --verbose
```

## Platform Compatibility

The Ruby-based scripts work on multiple platforms:

- **macOS**: Fully supported
- **Linux**: Fully supported
- **Windows**: Works with WSL (Windows Subsystem for Linux)

## Advanced Usage

### Using Your Own Repository

1. After running the installer, navigate to your project directory:
   ```zsh
   cd ~/projects/6-7-coding-challenge
   ```

2. Set up your own GitHub repository:
   ```zsh
   git remote add origin https://github.com/yourusername/your-repo-name.git
   ```

3. Push your initial commit:
   ```zsh
   git push -u origin main
   ```

### Adapting the Challenge for Different Skills

You can modify the challenge structure in your configuration:

```zsh
# Change to focus on different technologies
ccconfig --set "challenge.phases.1.name=Go Backend"
ccconfig --set "challenge.phases.1.dir=phase1_go"
```

For complete customization options, see [Customization Guide](customization.md).

## Next Steps

Now that you're set up, here are your next steps:

1. Run `ccstart` to begin your first day
2. Familiarize yourself with the project templates in the [Templates Guide](project-templates.md)
3. Check out [About the Challenge](about.md) to understand the philosophy behind the 6/7 approach
4. Join the community by posting about your journey with #67CodingChallenge

Happy coding, and enjoy your 500-day journey to mastery!
