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
