# 6/7 Coding Challenge

A personal commitment to code for 500 days, six days a week (Monday through Saturday), while observing the Sabbath rest on Sundays.

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
   
   ![Use this template button](https://docs.github.com/assets/cb-77734/mw-1440/images/help/repository/use-this-template-button.webp)

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

### What's Included in Your Template Repository

When you create a repository from this template, you'll get:

- The complete directory structure for all phases
- All automation scripts for daily tracking and logging
- Comprehensive documentation
- Initial setup for your first day

You will NOT get:
- My personal progress or logs
- CI/CD workflows specific to the original repository
- Template configuration files

This gives you a clean slate to start your own 6/7 Coding Challenge journey with all the infrastructure already in place!

### Personalizing Your Repository

After creating from the template, be sure to:

1. Update the README.md with your specific goals and plans
2. Customize the configuration using `ccconfig --interactive`
3. Set up your GitHub information for proper attribution
4. Modify phase content to match your learning objectives

## What Is It?

The 6/7 Coding Challenge is a structured approach to mastering software engineering through consistent practice while honoring the Sabbath. It combines:

1. **Daily Coding Practice**: 6 days per week (Monday-Saturday)
2. **Structured Learning Path**: 5 phases of 100 days each
3. **Documentation and Reflection**: Tracking progress and learnings
4. **Sabbath Rest**: Intentional pause every Sunday

The challenge is powered by a set of Ruby automation scripts that help maintain consistency, track progress, and simplify the daily workflow.

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

# Non-interactive mode (for automated setup)
ruby ~/bin/cc-installer.rb --non-interactive
```

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
- [Customization Guide](docs/CUSTOMIZATION.md): How to tailor the challenge to your needs
- [Scripts Documentation](scripts/README.md): Description of all scripts

## Creating Your Own Challenge

To create your own 6/7 Coding Challenge:

1. Use this repository as a template on GitHub
2. Clone your new repository
3. Follow the installation instructions above
4. Customize the configuration to match your preferences
5. Start your journey with `ccstart`

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by the human developer.

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Disclaimer

This is a personal development and learning project. The implementation has been upgraded to use Ruby for improved reliability and cross-platform compatibility.
