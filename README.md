# 6/7 Coding Challenge

A personal commitment to code for 500 days, six days a week (Monday through Saturday), while observing the Sabbath rest on Sundays.

## Current Phase
**Phase 1: Python Backend** (March 31 - June 29, 2025)

Building a strong foundation in server-side programming with Python, focusing on fundamentals, data structures, algorithms, and web servers while completing Launch School's Python track through course 189 and Algebra 2 coursework.

## Daily Schedule
- **5:00-5:30** - Devotions
- **5:30-6:00** - ANKI/Biking/Stretching
- **6:00-9:00** - Study Session 1 (60 minutes on, 5 minutes off)
- **10:00-1:00** - Study Session 2 (55 minutes on, 5 minutes off)
- **2:00-5:00** - Study Session 3 (50 minutes on, 10 minutes off)
- **5:00-6:30** - Math Lessons (odd days)
- **Evening** - Daily Kata/Equivalent (Rotating Languages: Ruby/Python, Bash/SQL, HTML/CSS)
- **9:00** - Bedtime

## 🚀 Quick Start

```zsh
# Clone the repository
git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
cd 6-7-coding-challenge

# Install the Ruby-based setup script
mkdir -p ~/bin
cp scripts/cc-installer.rb ~/bin/
chmod +x ~/bin/cc-installer.rb

# Run the installer (interactive)
ruby ~/bin/cc-installer.rb

# Source your .zshrc or restart your terminal
source ~/.zshrc

# Start your first day
ccstart
```

## Using This Repository as a Template

This repository is set up as a GitHub template, making it easy to create your own 6/7 Coding Challenge repository without forking or copying files manually.

### Creating Your Repository from This Template

1. **Navigate to the template repository**: Go to [github.com/joshuamichaelhall-tech/6-7-coding-challenge](https://github.com/joshuamichaelhall-tech/6-7-coding-challenge)

2. **Click the "Use this template" button**: Look for the green button near the top of the repository page.

3. **Create a new repository**:
   - Enter a name for your repository (e.g., "my-coding-challenge")
   - Choose visibility (public or private)
   - Click "Create repository from template"

4. **Clone your new repository**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
   cd YOUR-REPO-NAME
   ```

5. **Run the installer**:
   ```bash
   mkdir -p ~/bin
   cp scripts/cc-installer.rb ~/bin/
   chmod +x ~/bin/cc-installer.rb
   ruby ~/bin/cc-installer.rb
   ```

6. **Customize the configuration**:
   Follow the interactive prompts to personalize your challenge settings.

7. **Start your journey**:
   ```bash
   source ~/.zshrc
   ccstart
   ```

## Five Phase Structure

The challenge is divided into five phases:

### Phase 1: Python Backend (March 31 - June 29, 2025)
Building a strong foundation in server-side programming with Python, focusing on fundamentals, data structures, algorithms, and web servers.

### Phase 2: JavaScript Frontend (June 30 - November 2, 2025)
Developing frontend skills with JavaScript, HTML, and CSS, including modern frameworks and interactive visualization.

### Phase 3: Capstone Prep (November 3 - January 4, 2026)
Preparing for Launch School's Capstone program, networking, and solidifying technical foundations.

### Phase 4: Capstone (January 5 - June 28, 2026)
Participating in Launch School's Capstone program, working on real-world projects with a team.

### Phase 5: Career Development (June 29, 2026 onward)
Specializing in machine learning applications for finance, preparing for future career goals in the ML finance sector.

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
| `ccuninstall` | Remove scripts and configuration                   |

## Daily Workflow

1. **Start your day**: Run `ccstart` to set up your environment
2. **Write code**: Work on your daily project
3. **Document**: Fill in your README.md with goals and reflections
4. **Log progress**: Run `cclog` to update your weekly log
5. **Commit**: Run `ccpush` to commit changes and increment day counter

## Prerequisites

- **Ruby**: For script execution
- **zsh**: As your shell
- **git**: For version control

Optional but recommended:
- **tmux**: For terminal session management
- **neovim** or **vim**: For editing files

## New Feature: Customization

You can now customize the 6/7 Coding Challenge to your preferences:

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

## New Feature: Retroactive Logging

You can now log entries for previous days:

```zsh
# Log the current day (normal usage)
cclog

# Log a specific previous day
cclog 5  # Logs day 5 specifically
```

This is useful if you forget to log on a particular day.

## Project Philosophy

This challenge follows several key principles:

1. **Mastery over Surface Knowledge**: Focus on deep understanding
2. **Consistency over Intensity**: Regular, moderate practice
3. **Application over Theory**: Hands-on projects
4. **Documentation over Silent Progress**: Regular reflection
5. **Structure over Randomness**: Organized approach
6. **Rest as Essential**: Recognition that regular rest enhances productivity

## For More Information

See these documentation files for more details:

- [About The Challenge](ABOUT.md): Philosophy and motivation
- [Getting Started Guide](docs/getting-started.md): Detailed setup instructions
- [Customization Guide](CUSTOMIZATION.md): How to tailor the challenge to your needs
- [Scripts Documentation](scripts/README.md): Description of all scripts

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Disclaimer

This is a personal development and learning project. The implementation has been upgraded to use Ruby for improved reliability and cross-platform compatibility.
