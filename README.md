# 6/7 Coding Challenge

**⚠️ DISCLAIMER: This is a work in progress. The implementation has been upgraded to use Ruby for improved reliability and cross-platform compatibility.**

## Overview

The 6/7 Coding Challenge is a personal commitment to code for 500 days, six days a week (Monday through Saturday), while observing the Sabbath rest on Sundays. It's designed to build programming mastery through consistent practice while maintaining a sustainable pace that respects religious observance.

## Quick Start

```zsh
# Clone the repository
git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
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

## What Is It?

The 6/7 Coding Challenge is a structured approach to mastering software engineering through consistent practice while honoring the Sabbath. It combines:

1. **Daily Coding Practice**: 6 days per week (Monday-Saturday)
2. **Structured Learning Path**: 5 phases of 100 days each
3. **Documentation and Reflection**: Tracking progress and learnings
4. **Sabbath Rest**: Intentional pause every Sunday

The challenge is powered by a set of automation scripts that help maintain consistency, track progress, and simplify the daily workflow.

## Five Phase Structure

The challenge is divided into five 100-day phases:

### Phase 1: Ruby Backend (Days 1-100)
Building a strong foundation in server-side programming with Ruby, focusing on fundamentals, data structures, algorithms, and basic web servers with Sinatra.

### Phase 2: Python Data Analysis (Days 101-200)
Developing data analysis skills with Python, focusing on libraries like Pandas, NumPy, and Matplotlib, with an introduction to machine learning concepts.

### Phase 3: JavaScript Frontend (Days 201-300)
Building client-side programming skills with JavaScript, HTML, and CSS, including modern frameworks and interactive visualization.

### Phase 4: Full-Stack Projects (Days 301-400)
Integrating backend and frontend skills to create complete web applications, focusing on CRUD operations, authentication, and deployment.

### Phase 5: ML Finance Applications (Days 401-500)
Specializing in machine learning applications for finance, preparing for future career goals in the ML finance sector.

## Core Commands

After installation, these commands will be available:

| Command    | Description                                           |
|------------|-------------------------------------------------------|
| `ccstart`  | Start the day's coding session in tmux                |
| `cclog`    | Record your progress in the weekly log                |
| `ccpush`   | Commit changes and increment the day counter          |
| `ccstatus` | Show your overall challenge progress                  |
| `ccupdate` | Update scripts to the latest version                  |
| `ccuninstall` | Remove scripts and configuration                   |

## Prerequisites

The scripts require these tools to be installed:

- **Ruby**: For the installer and script execution
- **zsh**: As your shell
- **git**: For version control

Optional but recommended:
- **tmux**: For terminal session management (falls back gracefully if not available)
- **neovim** or **vim**: For editing files (uses your default editor if neither is available) 

## Installation Options

The Ruby installer script offers multiple modes:

```zsh
# Standard installation
ruby ~/bin/cc-installer.rb

# Force reinstallation
ruby ~/bin/cc-installer.rb --install

# Update an existing installation 
ruby ~/bin/cc-installer.rb --update
# or use the alias after installation:
ccupdate

# Uninstall
ruby ~/bin/cc-installer.rb --uninstall
# or use the alias after installation:
ccuninstall

# Verbose output for troubleshooting
ruby ~/bin/cc-installer.rb --verbose
```

## New Feature: Retroactive Logging

You can now log entries for previous days:

```zsh
# Log the current day (normal usage)
cclog

# Log a specific previous day
cclog 5  # Logs day 5 specifically
```

This is useful if you forget to log on a particular day.

## For More Information

See the following documentation files for more details:

- [Getting Started Guide](getting-started.md): Detailed instructions for beginners
- [Scripts Documentation](scripts/README.md): Complete documentation of all scripts
- [About the Challenge](ABOUT.md): Philosophy and motivation behind the challenge
- [Implementation Guide](implementation-guide.md): Detailed guide for the Ruby installer

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by the human developer.

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.
