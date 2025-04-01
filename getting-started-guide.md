# Getting Started with the 6/7 Coding Challenge

Welcome to the 6/7 Coding Challenge! This guide will help you set up your environment and start your 500-day journey of consistent coding practice while observing the Sabbath.

## What is the 6/7 Coding Challenge?

The 6/7 Coding Challenge is a personal commitment to code for 500 days, six days a week (Monday through Saturday), while observing the Sabbath rest on Sundays. The challenge is structured in five phases, each focusing on different aspects of software engineering:

1. **Ruby Backend** (Days 1-100)
2. **Python Data Analysis** (Days 101-200)
3. **JavaScript Frontend** (Days 201-300)
4. **Full-Stack Projects** (Days 301-400)
5. **ML Finance Applications** (Days 401-500)

## Quick Start Guide

### 1. Clone the Repository

```zsh
git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
cd 6-7-coding-challenge
```

### 2. Run the Setup Script

The setup script will create necessary directories, install challenge scripts, and set up your environment:

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
   - This will check if it's a Sabbath (Sunday)
   - Create the appropriate directory structure
   - Initialize a README template
   - Open a tmux session in the right location

2. **Work on your daily challenge goals**
   - Fill in the README with your goals and progress
   - Complete your coding for the day

3. **Log your progress** with `cclog`
   - This extracts information from your README
   - Appends it to the weekly log file

4. **Commit and push your work** with `ccpush`
   - Commits all changes with a standardized message
   - Pushes to the remote repository
   - Increments the day counter for tomorrow

5. **Check your progress** with `ccstatus`
   - Shows your current day, phase, and week
   - Calculates your progress percentage
   - Estimates your completion date

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

## Understanding the Challenge Structure

### Weekly and Daily Structure

- Each **week** consists of 6 coding days (Monday-Saturday)
- The **Sabbath** (Sunday) is reserved for rest
- Each **day** has a structured README template with:
  - Today's focus (primary, secondary, and stretch goals)
  - Launch School connection
  - Progress log
  - Reflections

### Phase Structure

- Each **phase** consists of 100 coding days
- Each phase focuses on a different aspect of software engineering
- Phase 1 (Ruby Backend) is further detailed in `docs/ruby-portfolio-plan.md`

## Troubleshooting

### Common Issues

1. **Script permissions**:
   ```zsh
   ls -la ~/bin
   # If needed: chmod +x ~/bin/cc-*.sh
   ```

2. **Day counter not found**:
   ```zsh
   echo "1" > ~/.cc-current-day
   ```

3. **tmux errors**:
   ```zsh
   # Check if tmux is installed
   which tmux
   # If not: brew install tmux
   ```

4. **Script errors**:
   ```zsh
   # Try running the script with debugging
   zsh -x ~/bin/cc-start-day.sh
   ```

## Online Integration

This challenge is designed to be shared publicly:

- **GitHub**: Regular commits show your consistency
- **Twitter/X**: Daily updates using #67CodingChallenge
- **Dev.to/Medium**: Weekly and monthly reflections
- **LinkedIn**: Monthly progress updates

See `docs/website-social-guide.md` for a comprehensive plan.

## Customizing Your Challenge

Feel free to customize aspects of this challenge:

1. **Modify the README template** in `cc-start-day.sh`
2. **Change the tmux layout** to suit your workflow
3. **Adjust the project structure** as needed
4. **Create additional scripts** for your specific needs

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

Happy coding!
