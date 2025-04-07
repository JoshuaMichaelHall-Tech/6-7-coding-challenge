# Sample 6/7 Coding Challenge Configurations

This document provides example configurations for different use cases of the 6/7 Coding Challenge. Use these as starting points for your own customized challenge.

## How to Use These Configurations

You can apply these configurations using the `ccconfig` command:

```bash
# Save a configuration to a file
ccconfig > my-config.json

# Edit the file with your preferred settings
vim my-config.json

# Load the configuration
cat my-config.json | ccconfig --reset
```

Alternatively, you can set individual values:

```bash
ccconfig --set "challenge.phases.1.name=Web Development"
```

## 1. Standard Challenge Configuration

The default configuration follows Joshua's original 6/7 Coding Challenge structure:

```json
{
  "version": "3.0.0",
  "user": {
    "name": "Your Name",
    "github_username": "yourusername",
    "github_email": "your@email.com"
  },
  "paths": {
    "base_dir": "~/projects/6-7-coding-challenge",
    "bin_dir": "~/bin"
  },
  "preferences": {
    "editor": "nvim",
    "use_tmux": true,
    "auto_push": true,
    "display_colors": true
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

## 2. Web Development Focus

For those focusing on web development skills:

```json
{
  "version": "3.0.0",
  "challenge": {
    "phases": {
      "1": { "name": "HTML/CSS Foundations", "dir": "phase1_html_css" },
      "2": { "name": "JavaScript Essentials", "dir": "phase2_javascript" },
      "3": { "name": "Frontend Frameworks", "dir": "phase3_frameworks" },
      "4": { "name": "Backend Development", "dir": "phase4_backend" },
      "5": { "name": "Full-Stack Projects", "dir": "phase5_fullstack" }
    },
    "days_per_week": 6,
    "days_per_phase": 60,
    "total_days": 300
  }
}
```

## 3. Data Science Path

For those pursuing data science and machine learning:

```json
{
  "version": "3.0.0",
  "challenge": {
    "phases": {
      "1": { "name": "Python Fundamentals", "dir": "phase1_python" },
      "2": { "name": "Data Analysis", "dir": "phase2_data_analysis" },
      "3": { "name": "Machine Learning", "dir": "phase3_ml" },
      "4": { "name": "Deep Learning", "dir": "phase4_deep_learning" },
      "5": { "name": "MLOps & Deployment", "dir": "phase5_mlops" }
    },
    "days_per_week": 5,
    "days_per_phase": 60,
    "total_days": 300
  }
}
```

## 4. Mobile Development Track

For those focusing on mobile app development:

```json
{
  "version": "3.0.0",
  "challenge": {
    "phases": {
      "1": { "name": "Swift Fundamentals", "dir": "phase1_swift" },
      "2": { "name": "iOS UI Development", "dir": "phase2_ios_ui" },
      "3": { "name": "iOS Architecture", "dir": "phase3_ios_architecture" },
      "4": { "name": "Cross-Platform (React Native)", "dir": "phase4_react_native" },
      "5": { "name": "App Store & Publication", "dir": "phase5_app_store" }
    },
    "days_per_week": 5,
    "days_per_phase": 40,
    "total_days": 200
  }
}
```

## 5. DevOps and Cloud

For those pursuing DevOps and cloud skills:

```json
{
  "version": "3.0.0",
  "challenge": {
    "phases": {
      "1": { "name": "Linux & Bash", "dir": "phase1_linux" },
      "2": { "name": "Docker & Containers", "dir": "phase2_containers" },
      "3": { "name": "CI/CD Pipelines", "dir": "phase3_cicd" },
      "4": { "name": "Cloud Platforms (AWS)", "dir": "phase4_aws" },
      "5": { "name": "Infrastructure as Code", "dir": "phase5_iac" }
    },
    "days_per_week": 5,
    "days_per_phase": 50,
    "total_days": 250
  }
}
```

## 6. Shorter Challenge (100 Days)

For those who prefer a shorter commitment:

```json
{
  "version": "3.0.0",
  "challenge": {
    "phases": {
      "1": { "name": "Fundamentals", "dir": "phase1_fundamentals" },
      "2": { "name": "Projects", "dir": "phase2_projects" }
    },
    "days_per_week": 5,
    "days_per_phase": 50,
    "total_days": 100
  }
}
```

## 7. Weekend-Only Challenge

For those who can only code on weekends:

```json
{
  "version": "3.0.0",
  "challenge": {
    "phases": {
      "1": { "name": "Backend", "dir": "phase1_backend" },
      "2": { "name": "Frontend", "dir": "phase2_frontend" },
      "3": { "name": "Projects", "dir": "phase3_projects" }
    },
    "days_per_week": 2,
    "days_per_phase": 40,
    "total_days": 120
  }
}
```

## 8. Computer Science Fundamentals

For those focusing on CS fundamentals:

```json
{
  "version": "3.0.0",
  "challenge": {
    "phases": {
      "1": { "name": "Algorithms & Data Structures", "dir": "phase1_algorithms" },
      "2": { "name": "Computer Architecture", "dir": "phase2_architecture" },
      "3": { "name": "Operating Systems", "dir": "phase3_os" },
      "4": { "name": "Databases", "dir": "phase4_databases" },
      "5": { "name": "Computer Networks", "dir": "phase5_networks" }
    },
    "days_per_week": 5,
    "days_per_phase": 60,
    "total_days": 300
  }
}
```

## Customizing These Examples

These configurations only show changes to the `challenge` section. Remember to customize:

1. Your `user` information
2. Your preferred `paths`
3. Your `preferences` for editors and tools

For example, to use VS Code instead of Neovim:

```bash
ccconfig --set preferences.editor=code
```

## Environment-Specific Configurations

### macOS Configuration

```bash
ccconfig --set paths.base_dir=~/Documents/coding-challenge
```

### Linux Configuration

```bash
ccconfig --set paths.base_dir=~/code/coding-challenge
```

### Windows (WSL) Configuration

```bash
ccconfig --set paths.base_dir=/mnt/c/Users/YourUsername/Projects/coding-challenge
```

## Creating Your Own Configuration

The best approach is to run the interactive configuration:

```bash
ccconfig --interactive
```

This will guide you through all the options and create a configuration tailored to your needs.

Remember that you can modify your configuration at any time during the challenge!
