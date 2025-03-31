#!/bin/zsh

# 6/7 Coding Challenge Repository Setup Script
# This script creates the recommended directory structure for the challenge repository

echo "Setting up 6/7 Coding Challenge repository structure..."

# Check if a directory name was provided
if [[ $# -eq 0 ]]; then
  REPO_DIR="$HOME/projects/6-7-coding-challenge"
  echo "No directory specified, using default: $REPO_DIR"
else
  REPO_DIR="$1"
  echo "Setting up repository in: $REPO_DIR"
fi

# Create the main repository directory
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# Create the main directories
echo "Creating directory structure..."
mkdir -p docs logs/{phase1,phase2,phase3,phase4,phase5} scripts
mkdir -p phase1_ruby phase2_python phase3_javascript phase4_fullstack phase5_ml_finance

# Create week directories for phase 1 (first 17 weeks)
echo "Creating initial week directories for Phase 1..."
for i in {01..17}; do 
  mkdir -p "phase1_ruby/week$i"
done

# Create day directories for the first week
echo "Creating day directories for Week 1..."
for i in {1..6}; do
  mkdir -p "phase1_ruby/week01/day$i"
done

# Create placeholder README files
echo "Creating placeholder README files..."

# Main README
cat > "$REPO_DIR/README.md" << 'EOF'
# 6/7 Coding Challenge

> "Master the basics. Then practice them every day without fail." - John C. Maxwell

A 500-day coding challenge (6 days per week) aligned with Launch School's mastery-based learning approach.

## Challenge Overview

The 6/7 Coding Challenge is my commitment to code for 500 days (Monday through Saturday) while observing the Sabbath rest on Sundays. This structured approach allows for consistent skill development while honoring religious observance and preventing burnout.

## Challenge Structure

The challenge is divided into 5 phases of 100 days each:

1. **Foundation Phase (Days 1-100)**: Ruby backend development
2. **Data Phase (Days 101-200)**: Python data analysis/ML foundations
3. **Interface Phase (Days 201-300)**: JavaScript frontend
4. **Integration Phase (Days 301-400)**: Full-stack projects
5. **Specialization Phase (Days 401-500)**: ML finance applications

Each week consists of 6 coding days (Monday-Saturday) with Sunday reserved for rest.

## Current Status

- **Current Day**: [Day Number]/500
- **Current Phase**: [Phase Number]/5
- **Current Week**: [Week Number]
- **Progress**: [Percentage]% complete

## Phase 1 Progress: Ruby Backend

<!-- This section will be updated as I progress -->

### Completed Projects
- (To be filled in as projects are completed)

### Key Learnings
- (To be filled in as the challenge progresses)

## Weekly Logs

Weekly progress logs are available in the [logs](./logs) directory.

## Challenge Rules

1. Code for at least 1 hour every Monday through Saturday
2. Each day must include meaningful progress toward the phase's theme
3. All code must be committed and pushed to this repository
4. Weekly reflections must be written each Saturday
5. No coding on Sundays (Sabbath rest)

## Launch School Integration

This challenge is designed to complement my Launch School journey. Each day's work is aligned with Launch School's curriculum, providing additional practice and project-based learning.

## Tech Stack

| Phase | Primary Language | Secondary Technologies |
|-------|------------------|------------------------|
| 1 | Ruby | Sinatra, PostgreSQL |
| 2 | Python | Pandas, NumPy, Matplotlib |
| 3 | JavaScript | HTML, CSS, React |
| 4 | Ruby/JavaScript | Rails, React, PostgreSQL |
| 5 | Python | TensorFlow, PyTorch, Financial APIs |

## Follow My Progress

- [GitHub](https://github.com/joshuamichaelhall-tech)
- [Twitter/X](https://twitter.com/joshuahalltech)
- [Dev.to](https://dev.to/joshuamichaelhall)
- [LinkedIn](https://www.linkedin.com/in/joshuamichaelhall/)

## Additional Resources

In addition to this repository's core content, the following resources are available:
- [6/7 Coding Challenge Guide](./ABOUT.md) - Comprehensive guide to the challenge
- [Website & Social Media Integration Guide](./docs/website-social-guide.md) - Implementation plan for online presence
- [Article Outlines](./docs/) - Outlines for Medium and Dev.to articles about the challenge
- [Scripts Documentation](./scripts/README.md) - Documentation for challenge automation scripts

## Resources

- [Challenge Guide](./ABOUT.md)
- [Launch School](https://launchschool.com)
- [Scripts Documentation](./scripts/README.md)

---

Started on: $(date +"%Y-%m-%d")  
Estimated completion: $(date -v+500d +"%Y-%m-%d")
EOF

# ABOUT.md
cat > "$REPO_DIR/ABOUT.md" << 'EOF'
# About the 6/7 Coding Challenge

## What Is It?

The 6/7 Coding Challenge is a personal commitment to code for 500 days, six days a week (Monday through Saturday), while observing the Sabbath rest on Sundays. It's designed to build programming mastery through consistent practice while maintaining a sustainable pace that respects religious observance.

## Why This Challenge?

The traditional "100 days of code" or similar challenges often encourage daily coding without breaks. This modified challenge acknowledges the importance of regular rest while still maintaining the discipline and consistency that builds skills.

### Benefits:

1. **Skill Development**: Consistent practice of programming fundamentals
2. **Portfolio Building**: Creation of numerous projects across different domains
3. **Career Advancement**: Demonstrated commitment to software engineering excellence
4. **Structured Learning**: Alignment with Launch School's mastery-based approach
5. **Sustainable Pace**: Prevention of burnout through regular rest
6. **Value Alignment**: Honoring religious observance while pursuing professional growth

## Challenge Philosophy

This challenge follows several key principles:

1. **Mastery over Surface Knowledge**: Focus on deep understanding rather than superficial exposure
2. **Consistency over Intensity**: Regular, moderate practice is more effective than sporadic intense sessions
3. **Application over Theory**: Hands-on projects that apply concepts learned through Launch School
4. **Documentation over Silent Progress**: Regular reflection and public sharing of the journey
5. **Structure over Randomness**: Organized phases targeting specific skill areas
6. **Rest as Essential**: Recognition that regular rest enhances productivity and creativity

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

## Launch School Integration

This challenge is designed to complement the Launch School curriculum:

- Challenge projects apply concepts learned in Launch School courses
- Weekly planning aligns challenge work with current Launch School material
- Project structure matches Launch School's emphasis on mastery
- Challenge phases build toward career goals beyond Launch School

## Measuring Success

Success in this challenge is measured by:

1. **Consistency**: Completing the required days of coding
2. **Portfolio Growth**: Number and quality of projects created
3. **Skill Development**: Mastery of targeted technologies
4. **Documentation**: Quality of reflections and logs
5. **Knowledge Integration**: Application of Launch School concepts
6. **Career Advancement**: Progress toward software engineering and ML finance goals

## Documentation

For a complete implementation plan including website integration, social media strategy, and article publishing guidelines, see the [Website & Social Media Integration Guide](./docs/website-social-guide.md) in the docs directory.

## Challenge Origins

This challenge was inspired by traditional coding challenges but modified to align with personal values and career goals. It combines elements of:

- Traditional "X days of code" challenges
- Launch School's mastery-based learning approach
- Religious observance of the Sabbath
- Long-term career planning for software engineering and ML finance

## Join Me or Create Your Own Version

Feel free to fork this repository and adapt the challenge to your own needs and values. Whether you follow the same structure or modify it, the key principles of consistency, rest, and mastery can benefit any learning journey.
EOF

# Scripts README
cat > "$REPO_DIR/scripts/README.md" << 'EOF'
# 6/7 Coding Challenge Scripts

This directory contains the automation scripts that power the 6/7 Coding Challenge. These scripts help maintain consistency, track progress, and simplify the daily workflow.

## Script Overview

| Script | Description |
|--------|-------------|
| `cc-start-day.sh` | Initializes the environment for a new challenge day |
| `cc-log-progress.sh` | Records the day's progress in the weekly log file |
| `cc-push-updates.sh` | Commits and pushes changes, increments the day counter |
| `cc-status.sh` | Displays the current challenge status and progress |
| `cc-setup.sh` | One-time setup script for the challenge environment |

## Installation

1. Clone the repository:
   ```zsh
   git clone https://github.com/joshuamichaelhall-tech/6-7-coding-challenge.git
   cd 6-7-coding-challenge
   ```

2. Run the setup script:
   ```zsh
   zsh scripts/cc-setup.sh
   ```

3. Add these aliases to your `.zshrc`:
   ```zsh
   # 6/7 Coding Challenge aliases
   alias ccstart="~/bin/cc-start-day.sh"
   alias cclog="~/bin/cc-log-progress.sh"
   alias ccpush="~/bin/cc-push-updates.sh"
   alias ccstatus="~/bin/cc-status.sh"
   ```

4. Source your `.zshrc` or restart your terminal:
   ```zsh
   source ~/.zshrc
   ```

## Daily Workflow

1. Start your day:
   ```zsh
   ccstart
   ```
   This opens a tmux session with your challenge environment.

2. After your coding session, log your progress:
   ```zsh
   cclog
   ```

3. Push your changes and increment the day counter:
   ```zsh
   ccpush
   ```

4. Check your overall progress:
   ```zsh
   ccstatus
   ```

## Script Details

### cc-start-day.sh

This script:
- Calculates the current phase, week, and day
- Checks if it's Sunday and reminds you to rest if it is
- Creates the appropriate directory structure
- Initializes a README template for the day
- Opens a tmux session with the right directory and files

### cc-log-progress.sh

This script:
- Extracts the progress and reflections from your day's README
- Appends them to the weekly log file
- Formats the content appropriately

### cc-push-updates.sh

This script:
- Adds all changes to git
- Commits with a standardized commit message
- Pushes to the remote repository
- Increments the day counter for tomorrow

### cc-status.sh

This script:
- Shows your current day, phase, and week
- Calculates your overall progress percentage
- Estimates your completion date
- Displays days remaining

### Custom Modifications

Feel free to modify these scripts to better suit your workflow. Some common modifications include:

- Changing the tmux layout in `cc-start-day.sh`
- Modifying the README template in `cc-start-day.sh`
- Customizing the commit message format in `cc-push-updates.sh`
- Adding additional statistics to `cc-status.sh`

## Troubleshooting

If you encounter issues:

1. Check script permissions:
   ```zsh
   ls -la ~/bin
   ```

2. Ensure day counter exists:
   ```zsh
   cat ~/.cc-current-day
   ```

3. Verify directory structure:
   ```zsh
   ls -la ~/projects/6-7-coding-challenge
   ```

4. Check for tmux installation:
   ```zsh
   which tmux
   ```
EOF

# Repository Structure Document
cat > "$REPO_DIR/docs/repo-structure.md" << 'EOF'
# 6/7 Coding Challenge Repository Structure

This document outlines the recommended directory structure for the 6/7 Coding Challenge repository.

```
6-7-coding-challenge/
├── README.md                      # Main repository overview and status
├── ABOUT.md                       # Challenge philosophy and structure
├── docs/                          # Documentation directory
│   ├── website-social-guide.md    # Website & social media integration guide
│   ├── medium-outline.md          # Outline for Medium article
│   ├── devto-outline.md           # Outline for Dev.to article
│   └── repo-structure.md          # This document
├── logs/                          # Challenge logs by phase and week
│   ├── phase1/
│   │   ├── week01.md
│   │   ├── week02.md
│   │   └── ...
│   ├── phase2/
│   └── ...
├── phase1_ruby/                   # Phase 1 project directories
│   ├── week01/
│   │   ├── day01/
│   │   ├── day02/
│   │   └── ...
│   ├── week02/
│   └── ...
├── phase2_python/                 # Phase 2 project directories
├── phase3_javascript/             # Phase 3 project directories
├── phase4_fullstack/              # Phase 4 project directories
├── phase5_ml_finance/             # Phase 5 project directories
└── scripts/                       # Challenge automation scripts
    ├── README.md                  # Scripts documentation
    ├── cc-setup.sh                # Setup script
    ├── cc-start-day.sh            # Day starter script
    ├── cc-log-progress.sh         # Progress logger script
    ├── cc-push-updates.sh         # Git update script
    └── cc-status.sh               # Challenge status script
```

## Directory Structure Explanation

### Root Directory
- `README.md`: Primary repository documentation with challenge overview and current status
- `ABOUT.md`: Detailed explanation of the challenge philosophy, structure, and purpose

### Docs Directory
Contains all supplementary documentation:
- `website-social-guide.md`: Comprehensive guide for website and social media integration
- `medium-outline.md`: Outline for the Medium article about the challenge
- `devto-outline.md`: Outline for the Dev.to article about the challenge
- `repo-structure.md`: This document explaining the repository structure

### Logs Directory
Organized by phase and week to store progress logs:
- Each phase has its own directory (`phase1/`, `phase2/`, etc.)
- Each week has its own markdown file (`week01.md`, `week02.md`, etc.)
- Logs are generated automatically by the `cc-log-progress.sh` script

### Phase Directories
Separate directories for each challenge phase:
- `phase1_ruby/`: Days 1-100 focusing on Ruby backend development
- `phase2_python/`: Days 101-200 focusing on Python data analysis
- `phase3_javascript/`: Days 201-300 focusing on JavaScript frontend
- `phase4_fullstack/`: Days 301-400 focusing on full-stack projects
- `phase5_ml_finance/`: Days 401-500 focusing on ML finance applications

Each phase directory contains week directories, which contain day directories:
- `week01/day01/`: Project directory for the first day of the challenge
- `week01/day02/`: Project directory for the second day of the challenge
- And so on...

### Scripts Directory
Contains all automation scripts for the challenge:
- `README.md`: Documentation explaining how to use all scripts
- `cc-setup.sh`: One-time setup script for the challenge environment
- `cc-start-day.sh`: Script to initialize each day's environment
- `cc-log-progress.sh`: Script to log daily progress to weekly logs
- `cc-push-updates.sh`: Script to commit and push changes, increment day counter
- `cc-status.sh`: Script to display current challenge status and progress

## Implementation Notes

1. This structure should be created by running the `cc-setup.sh` script
2. Only Phase 1 directories are created initially; others are created as needed
3. The current day counter is stored in `~/.cc-current-day` (not in the repository)
4. All scripts are designed to work with this directory structure
5. The repository should be hosted in the organization GitHub account (`joshuamichaelhall-tech`)

This structure provides a clean, organized way to track progress through the 500-day challenge while making it easy to find specific projects and logs.
EOF

# Create placeholder files for week 1 logs
mkdir -p "$REPO_DIR/logs/phase1"
cat > "$REPO_DIR/logs/phase1/week01.md" << EOF
# Week 01 (Days 1-6)

Welcome to the first week of the 6/7 Coding Challenge!

## Day 1

<!-- This will be filled with your first day's progress -->
EOF

# Create placeholder README files for day directories
cat > "$REPO_DIR/phase1_ruby/week01/day1/README.md" << EOF
# Day 1 - Phase 1 (Week 01)

## Today's Focus
- [ ] Primary goal: 
- [ ] Secondary goal:
- [ ] Stretch goal:

## Launch School Connection
- Current course: 
- Concept application: 

## Progress Log
- Started: $(date +"%Y-%m-%d")
- 

## Reflections
-

EOF

# Create placeholder files for docs directory
cat > "$REPO_DIR/docs/medium-outline.md" << 'EOF'
# Medium Article Outline: The 6/7 Coding Challenge

## Title
**The 6/7 Coding Challenge: 500 Days of Deliberate Practice While Honoring the Sabbath**

## Subtitle
A sustainable approach to mastery-based learning for software engineers

<!-- Add the full Medium article outline here -->
EOF

cat > "$REPO_DIR/docs/devto-outline.md" << 'EOF'
# Dev.to Article Outline: The 6/7 Coding Challenge

## Title
**The 6/7 Coding Challenge: How I'm Coding for 500 Days While Respecting the Sabbath**

## Introduction
- Brief personal introduction (software engineering student at Launch School)
- The challenge concept: 500 days of coding, 6 days per week
- The core philosophy: mastery through consistent practice with intentional rest

<!-- Add the full Dev.to article outline here -->
EOF

cat > "$REPO_DIR/docs/website-social-guide.md" << 'EOF'
# 6/7 Coding Challenge
# Website & Social Media Integration Guide

*This guide is part of the [6/7 Coding Challenge](https://github.com/joshuamichaelhall-tech/6-7-coding-challenge) documentation.*

## Table of Contents
1. [Introduction](#introduction)
2. [Content Calendar & Distribution Strategy](#content-calendar--distribution-strategy)
3. [Website Integration Plan](#website-integration-plan)
4. [Social Media Strategy](#social-media-strategy)
5. [Article Publication Plan](#article-publication-plan)
6. [Weekly Implementation Checklist](#weekly-implementation-checklist)
7. [Content Templates](#content-templates)
8. [Automation Tools & Scripts](#automation-tools--scripts)
9. [Metrics & Analytics](#metrics--analytics)

<!-- Add the full Website & Social Media guide here -->
EOF

# Create script placeholders
touch "$REPO_DIR/scripts/cc-setup.sh"
touch "$REPO_DIR/scripts/cc-start-day.sh"
touch "$REPO_DIR/scripts/cc-log-progress.sh"
touch "$REPO_DIR/scripts/cc-push-updates.sh"
touch "$REPO_DIR/scripts/cc-status.sh"

# Initialize git repository
echo "Initializing git repository..."
cd "$REPO_DIR"
git init
git add .
git commit -m "Initial repository setup for 6/7 Coding Challenge"

echo ""
echo "Repository structure setup complete at: $REPO_DIR"
echo ""
echo "Next steps:"
echo "1. Fill in the placeholder files with your content"
echo "2. Add the automation scripts to the scripts directory"
echo "3. Run the cc-setup.sh script to set up your local environment"
echo "4. Push the repository to GitHub"
echo ""
echo "Good luck with your 6/7 Coding Challenge!"
