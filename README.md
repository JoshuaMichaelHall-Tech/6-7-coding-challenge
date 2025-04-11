# 6/7 Coding Challenge

A personal commitment to code for 500 days, six days a week (Monday through Saturday), while observing the Sabbath rest on Sundays.

## What Is This?

The 6/7 Coding Challenge is a structured approach to mastering software engineering through consistent practice while respecting the importance of regular rest. The "6/7" represents coding for six days each week while resting on the seventh (Sabbath).

## Current Phase
You're currently in: **Phase 1: Day 1**

## 🚀 Quick Start

```zsh
# Clone the repository
git clone https://github.com/yourusername/6-7-coding-challenge.git
cd 6-7-coding-challenge

# Install the Ruby-based setup script
mkdir -p ~/bin
cp scripts/cc-installer.rb ~/bin/
chmod +x ~/bin/cc-installer.rb

# Run the installer
ruby ~/bin/cc-installer.rb

# Source your .zshrc or restart your terminal
source ~/.zshrc

# Start your first day
ccstart
```

## Core Commands

After installation, these commands will be available:

| Command    | Description                                           |
|------------|-------------------------------------------------------|
| `ccstart`  | Start the day's coding session in tmux                |
| `cclog`    | Record your progress in the weekly log                |
| `ccpush`   | Commit changes and increment the day counter          |
| `ccstatus` | Show your overall challenge progress                  |
| `ccconfig` | View or modify your configuration                     |
| `ccupdate` | Update scripts to the latest version                  |
| `ccbackup` | Backup logs and configuration                         |
| `ccrestore`| Restore logs from a backup                           |
| `ccuninstall` | Remove scripts and configuration                   |

## Key Features

The 6/7 Coding Challenge includes several powerful features to enhance your learning journey:

### Backup and Restore System

Maintain your progress across different computers or through system changes:

- **Local Backup**: Save logs to a timestamped directory in your home folder
- **Git Repository**: Create special branches for logs in your repository
- **Custom Location**: Specify any directory for your backup
- **Simple Restore**: Easily restore from any backup source with `ccrestore`

```zsh
# Create a backup of your logs
ccbackup

# Restore from a previous backup
ccrestore
```

### Flexible Phase Management

Adapt your challenge structure without losing past progress:

- **Interactive Configuration**: Update phases with guided prompts
- **Customizable Structure**: Modify phase names, directories, and durations
- **Safe Updates**: Change your challenge structure without losing logs

```zsh
# Update configuration interactively
ccconfig --interactive

# Update specific phase information
ccconfig --set "challenge.phases.1.name=New Phase Name"
```

### Retroactive Logging

Never lose track of your progress, even if you forget to log:

- **Log Previous Days**: Add entries for days you've completed but forgotten to log
- **Chronological Ordering**: Automatically places entries in the correct sequence
- **Duplicate Handling**: Smart replacement of existing entries

```zsh
# Log the current day (standard usage)
cclog

# Log a specific previous day
cclog 5  # Logs day 5 retroactively
```

### Project Templates

Start each day with well-structured project templates:

- **Phase-Specific Templates**: Tailored for different technologies
- **Consistent Structure**: Maintain a uniform approach across your challenge
- **Customizable**: Adapt templates to your specific needs

## Daily Workflow

1. **Start your day**: Run `ccstart` to set up your environment
2. **Write code**: Work on your daily project
3. **Document**: Fill in your README.md with goals and reflections
4. **Log progress**: Run `cclog` to update your weekly log
5. **Commit**: Run `ccpush` to commit changes and increment day counter

## Challenge Structure Examples

The challenge is highly customizable. Here are some examples of how you might structure it:

### Default Structure (Single Phase)
A simple 500-day coding journey:
- **Phase 1: Coding Challenge** - 500 days of consistent practice

### Five-Phase Example (Technology Learning Path)
A comprehensive programming language journey:

1. **Phase 1: Backend Fundamentals** (100 days)
   - Building server-side applications and mastering core language concepts
   
2. **Phase 2: Data Science & Analysis** (100 days)
   - Working with data processing, visualization, and analysis tools
   
3. **Phase 3: Frontend Development** (100 days)
   - Creating responsive user interfaces and interactive experiences
   
4. **Phase 4: Full-Stack Projects** (100 days)
   - Integrating backend and frontend in complete applications
   
5. **Phase 5: Specialization** (100 days)
   - Focusing on a specific area like ML, mobile development, or cloud

### Three-Phase Example (Project-Based)
A focused project creation journey:

1. **Phase 1: Learning Fundamentals** (100 days)
   - Mastering core technologies and concepts
   
2. **Phase 2: Building Projects** (200 days)
   - Creating 10 complete projects of increasing complexity
   
3. **Phase 3: Advanced Specialization** (200 days)
   - Focusing on large-scale applications in your desired specialty

## Documentation

For more detailed information, check out these guides:

- [Getting Started](docs/getting-started.md): Complete setup instructions
- [About the Challenge](docs/ABOUT.md): Philosophy and motivation
- [Customization Guide](docs/CUSTOMIZATION.md): How to tailor the challenge to your needs
- [Project Templates](docs/project-templates.md): Templates for each phase
- [Documentation Index](DOCUMENTATION.md): All available documentation

## Project Philosophy

This challenge follows several key principles:

1. **Mastery over Surface Knowledge**: Focus on deep understanding
2. **Consistency over Intensity**: Regular, moderate practice
3. **Application over Theory**: Hands-on projects
4. **Documentation over Silent Progress**: Regular reflection
5. **Structure over Randomness**: Organized approach
6. **Rest as Essential**: Recognition that regular rest enhances productivity

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by the original creator.

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Disclaimer

This is a personal development and learning project. The code is provided as-is, with no guarantees or warranties. By using this codebase, you agree to use it at your own risk.