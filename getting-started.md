# Getting Started with the 6/7 Coding Challenge

Welcome to the 6/7 Coding Challenge! This guide will help you set up your environment and start your 500-day journey of consistent coding practice while observing the Sabbath.

## 🚀 Quick Start

```zsh
# Clone the repository
git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
cd 6-7-coding-challenge

# Run the setup script
zsh scripts/cc-setup.sh

# Source your .zshrc or restart your terminal
source ~/.zshrc

# Start your first day
ccstart
```

## What is the 6/7 Coding Challenge?

The 6/7 Coding Challenge is a personal commitment to code for 500 days, six days a week (Monday through Saturday), while observing the Sabbath rest on Sundays. The challenge is structured in five phases, each focusing on different aspects of software engineering:

1. **Ruby Backend** (Days 1-100)
2. **Python Data Analysis** (Days 101-200)
3. **JavaScript Frontend** (Days 201-300)
4. **Full-Stack Projects** (Days 301-400)
5. **ML Finance Applications** (Days 401-500)

## Prerequisites

Before beginning the challenge, ensure you have:

- **Git**: For version control (`git --version`)
- **tmux**: For terminal session management (`tmux -V`)
- **zsh**: As your shell (`echo $SHELL`)
- **Neovim**: Recommended editor (`nvim --version`)
- **Ruby**: For Phase 1 (`ruby -v`)

## Detailed Setup Guide

### 1. Clone the Repository

```zsh
git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
cd 6-7-coding-challenge
```

### 2. Run the Setup Script

The setup script will:
- Create necessary directories
- Install challenge scripts in `~/bin`
- Initialize the day counter
- Set up git repository with .gitignore
- Add aliases to your .zshrc

```zsh
zsh scripts/cc-setup.sh
```

### 3. Source Your .zshrc or Restart Your Terminal

```zsh
source ~/.zshrc
```

### 4. Start Your First Day

```zsh
ccstart
```

This will open a tmux session with the appropriate files for your first day.

## Core Commands

These commands will be available after running the setup script:

| Command    | Description                                           |
|------------|-------------------------------------------------------|
| `ccstart`  | Start the day's coding session in tmux                |
| `cclog`    | Record your progress in the weekly log                |
| `ccpush`   | Commit changes and increment the day counter          |
| `ccstatus` | Show your overall challenge progress                  |

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

## Sample README and Log Format

### Daily README Template

```markdown
# Day 1 - Phase 1 (Week 01)

## Today's Focus
- [ ] Primary goal: Implement user authentication system
- [ ] Secondary goal: Write tests for authentication
- [ ] Stretch goal: Add password reset functionality

## Launch School Connection
- Current course: LS180
- Concept application: Database design principles applied to user tables

## Progress Log
- Started: 2025-04-01 09:00
- Completed user model with validations
- Added authentication controller
- Implemented bcrypt for password hashing

## Reflections
- The bcrypt implementation was more straightforward than expected
- Need to refactor the validation logic to be more DRY
- Tomorrow will focus on test coverage
```

### Weekly Log Format

```markdown
# Week 01 (Days 1-6)

## Week Overview
- **Focus**: Authentication and user management
- **Launch School Connection**: LS180 Database Design
- **Weekly Goals**:
  - Complete authentication system
  - Write comprehensive tests
  - Deploy to staging environment

## Daily Logs

## Day 1
...

## Day 2
...
```

## Repository Structure

```
6-7-coding-challenge/
├── README.md                     # Challenge overview
├── ABOUT.md                      # Challenge philosophy
├── docs/                         # Documentation
│   ├── website-social-guide.md   # Website integration guide
│   ├── announcement-*.md         # Announcement templates
│   └── ruby-portfolio-plan.md    # Phase 1 project plan
├── logs/                         # Progress logs
│   └── phase1/
│       └── week01.md             # Weekly logs
├── phase1_ruby/                  # Phase 1 projects
│   └── week01/
│       └── day1/                 # Daily project directories
├── scripts/                      # Challenge automation scripts
│   ├── README.md                 # Scripts documentation
│   ├── cc-setup.sh               # Setup script
│   ├── cc-start-day.sh           # Day starter script
│   ├── cc-log-progress.sh        # Progress logger
│   ├── cc-push-updates.sh        # Git update script
│   └── cc-status.sh              # Progress tracker
└── .gitignore                    # Git ignore file
```

## Customization Options

You can customize various aspects of the challenge to better suit your needs:

### Project Structure Configuration

To modify the phase structure, edit these variables in the scripts:
- `TOTAL_DAYS`: Change the total number of challenge days (default: 500)
- `START_DATE`: Modify the start date (default: 2025-04-01)

### Template Customization

To customize the README template, edit the template in `cc-start-day.sh`:
```zsh
# Open cc-start-day.sh
nvim ~/bin/cc-start-day.sh

# Find the section with cat > $PROJECT_DIR/README.md
# Modify the template to your liking
```

### Adding Additional Scripts

Create custom scripts in `~/bin` with the prefix `cc-` for consistency:
```zsh
# Example: Create a weekly summary generator
nvim ~/bin/cc-weekly-summary.sh
chmod +x ~/bin/cc-weekly-summary.sh
```

### Status Display Options

The `ccstatus` command supports colorized output and includes:
- Current day and phase information
- Progress percentage
- Schedule tracking (ahead/behind)
- GitHub streak information
- Repository status

## Troubleshooting

### Common Issues and Solutions

#### Script Permission Issues

```zsh
# Check permissions
ls -la ~/bin

# Fix permissions
chmod +x ~/bin/cc-*.sh
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

### Logs and Diagnostics

All scripts include improved error reporting. If you encounter issues:

1. Check the output messages for specific errors
2. Verify file and directory permissions
3. Confirm that all prerequisites are installed
4. Try running the scripts with debug mode:
   ```zsh
   zsh -x ~/bin/cc-start-day.sh
   ```

## Online Integration

This challenge is designed to be shared publicly:

- **GitHub**: Regular commits show your consistency
- **Twitter/X**: Daily updates using #67CodingChallenge
- **Dev.to/Medium**: Weekly and monthly reflections
- **LinkedIn**: Monthly progress updates

See `docs/website-social-guide.md` for a comprehensive plan.

## Platform Compatibility

The challenge scripts have been improved to work on both macOS and Linux:

- **macOS**: Fully supported with native date handling
- **Linux**: Compatible with GNU date command
- **Windows**: Works with WSL (Windows Subsystem for Linux)

## Project Templates

### Phase 1: Ruby Backend

Each new Ruby project should follow this structure:

```
day<N>/
├── README.md              # Daily challenge documentation
├── lib/                   # Library code
│   └── main.rb            # Main application code
├── spec/                  # Tests
│   └── main_spec.rb       # Test specifications
└── Gemfile                # Dependencies
```

Sample `Gemfile`:
```ruby
source 'https://rubygems.org'

gem 'rspec', '~> 3.10'
gem 'rubocop', '~> 1.18', require: false
```

Phase-specific templates for other phases are coming soon.

## Progress Visualization

The `ccstatus` command now includes enhanced visualization:
- Colorized output for better readability
- Schedule tracking (ahead/behind)
- Current streak tracking
- Repository information

## Inspiration and Philosophy

Remember the core philosophy of this challenge:

- **Mastery over Surface Knowledge**: Focus on deep understanding
- **Consistency over Intensity**: Regular, moderate practice
- **Application over Theory**: Hands-on projects
- **Documentation over Silent Progress**: Regular reflection
- **Structure over Randomness**: Organized approach
- **Rest as Essential**: Honoring the Sabbath

As John C. Maxwell said: "Master the basics. Then practice them every day without fail."

## Need Help?

- Review the `scripts/README.md` file for detailed script documentation
- Check the `ABOUT.md` file for a deeper understanding of the challenge philosophy
- Explore the `docs/` directory for more resources
- Review this guide's troubleshooting section for common issues

Happy coding, and enjoy your 500-day journey to mastery!
