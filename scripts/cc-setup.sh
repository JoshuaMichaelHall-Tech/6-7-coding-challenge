#!/bin/zsh

# 6/7 Coding Challenge Setup Script
# This script sets up the environment for the 6/7 coding challenge

echo "Setting up your 6/7 Coding Challenge environment..."

# Check for required tools
if ! command -v git &> /dev/null; then
  echo "Error: git not found. Please install git and try again."
  exit 1
fi

if ! command -v tmux &> /dev/null; then
  echo "Warning: tmux not found. Please install tmux for best experience."
  echo "For macOS: brew install tmux"
  echo "For Ubuntu/Debian: sudo apt install tmux"
  echo ""
  read -p "Continue setup without tmux? (y/n): " continue_setup
  if [[ $continue_setup != "y" && $continue_setup != "Y" ]]; then
    echo "Setup cancelled."
    exit 1
  fi
fi

# Create bin directory if it doesn't exist
echo "Creating ~/bin directory if it doesn't exist..."
mkdir -p ~/bin || { echo "Error: Failed to create ~/bin directory"; exit 1; }

# Create cc-start-day.sh in bin directory
echo "Creating cc-start-day.sh..."
cat > ~/bin/cc-start-day.sh << 'EOF'
#!/bin/zsh

# Get current phase, week, and day
if [[ ! -f ~/.cc-current-day ]]; then
  echo "Error: Day counter file not found. Creating with default value of 1."
  echo "1" > ~/.cc-current-day
fi

CURRENT_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)
PHASE=$((($CURRENT_DAY-1)/100+1))
WEEK_IN_PHASE=$((($CURRENT_DAY-1)%100/6+1))
DAY_OF_WEEK=$(date +%u)

# Check if it's Sunday
if [[ $DAY_OF_WEEK -eq 7 ]]; then
  echo "Today is the Sabbath. Time for rest, not coding."
  exit 0
fi

# Format week with leading zero
WEEK_FORMATTED=$(printf "%02d" $WEEK_IN_PHASE)

# Set phase directory
case $PHASE in
  1) PHASE_DIR="phase1_ruby" ;;
  2) PHASE_DIR="phase2_python" ;;
  3) PHASE_DIR="phase3_javascript" ;;
  4) PHASE_DIR="phase4_fullstack" ;;
  5) PHASE_DIR="phase5_ml_finance" ;;
  *) 
    echo "Error: Invalid phase number: $PHASE"
    exit 1
    ;;
esac

# Base project directory
BASE_DIR=~/projects/6-7-coding-challenge
if [[ ! -d $BASE_DIR ]]; then
  echo "Error: Base project directory not found at $BASE_DIR"
  echo "Please run the setup script first."
  exit 1
fi

# Create directories if needed
PROJECT_DIR=$BASE_DIR/$PHASE_DIR/week$WEEK_FORMATTED/day$CURRENT_DAY
mkdir -p $PROJECT_DIR || { echo "Error: Failed to create project directory"; exit 1; }
mkdir -p $BASE_DIR/logs/phase$PHASE || { echo "Error: Failed to create log directory"; exit 1; }

# Initialize log file if needed
LOG_FILE=$BASE_DIR/logs/phase$PHASE/week$WEEK_FORMATTED.md
if [[ ! -f $LOG_FILE ]]; then
  echo "# Week $WEEK_FORMATTED (Days $((($WEEK_IN_PHASE-1)*6+1))-$((($WEEK_IN_PHASE)*6)))" > $LOG_FILE
  echo "" >> $LOG_FILE
  echo "## Week Overview" >> $LOG_FILE
  echo "- **Focus**: " >> $LOG_FILE
  echo "- **Launch School Connection**: " >> $LOG_FILE
  echo "- **Weekly Goals**:" >> $LOG_FILE
  echo "  - " >> $LOG_FILE
  echo "  - " >> $LOG_FILE
  echo "  - " >> $LOG_FILE
  echo "" >> $LOG_FILE
  echo "## Daily Logs" >> $LOG_FILE
  echo "" >> $LOG_FILE
fi

# Set up the day's work if README doesn't exist
if [[ ! -f $PROJECT_DIR/README.md ]]; then
  echo "Setting up Day $CURRENT_DAY (Phase $PHASE, Week $WEEK_FORMATTED)"
  cat > $PROJECT_DIR/README.md << EOF
# Day $CURRENT_DAY - Phase $PHASE (Week $WEEK_FORMATTED)

## Today's Focus
- [ ] Stretch goal:

## Launch School Connection
- Current course: 
- Concept application: 

## Progress Log
- Started: $(date +"%Y-%m-%d %H:%M")
- 

## Reflections
-

EOF
else
  echo "Using existing README for Day $CURRENT_DAY"
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
  echo "Error: tmux is not installed. Please install tmux and try again."
  echo "For macOS: brew install tmux"
  echo "For Ubuntu/Debian: sudo apt install tmux"
  exit 1
fi

# Check if session exists and kill it if it does
tmux has-session -t coding-challenge 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Existing session found. Killing it..."
  tmux kill-session -t coding-challenge
fi

# Create a new tmux session without attaching
tmux new-session -d -s coding-challenge -n "code"

# Configure the windows
tmux split-window -v -p 30 -t coding-challenge

# Send commands to each pane
tmux send-keys -t coding-challenge:0.0 "cd $PROJECT_DIR && clear" C-m
tmux send-keys -t coding-challenge:0.1 "cd $PROJECT_DIR && nvim README.md" C-m

# Attach to the session
echo "Attaching to tmux session..."
exec tmux attach-session -t coding-challenge
# Note: Any code after the exec won't run as exec replaces the current process
EOF

# Make the script executable
chmod +x ~/bin/cc-start-day.sh || { echo "Error: Failed to make script executable"; exit 1; }

# Create cc-log-progress.sh in bin directory
echo "Creating cc-log-progress.sh..."
cat > ~/bin/cc-log-progress.sh << 'EOF'
#!/bin/zsh

# Check if day counter exists
if [[ ! -f ~/.cc-current-day ]]; then
  echo "Error: Day counter file not found. Run setup script first."
  exit 1
fi

# Get current phase, week, and day
CURRENT_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)
PHASE=$((($CURRENT_DAY-1)/100+1))
WEEK_IN_PHASE=$((($CURRENT_DAY-1)%100/6+1))

# Format week with leading zero
WEEK_FORMATTED=$(printf "%02d" $WEEK_IN_PHASE)

# Set phase directory
case $PHASE in
  1) PHASE_DIR="phase1_ruby" ;;
  2) PHASE_DIR="phase2_python" ;;
  3) PHASE_DIR="phase3_javascript" ;;
  4) PHASE_DIR="phase4_fullstack" ;;
  5) PHASE_DIR="phase5_ml_finance" ;;
  *) 
    echo "Error: Invalid phase number: $PHASE"
    exit 1
    ;;
esac

# Base project directory
BASE_DIR=~/projects/6-7-coding-challenge
if [[ ! -d $BASE_DIR ]]; then
  echo "Error: Base project directory not found at $BASE_DIR"
  echo "Please run the setup script first."
  exit 1
fi

PROJECT_DIR=$BASE_DIR/$PHASE_DIR/week$WEEK_FORMATTED/day$CURRENT_DAY
LOG_FILE=$BASE_DIR/logs/phase$PHASE/week$WEEK_FORMATTED.md

# Check if project directory exists
if [[ ! -d $PROJECT_DIR ]]; then
  echo "Error: Project directory not found at $PROJECT_DIR"
  echo "Please run cc-start-day first."
  exit 1
fi

# Check if README exists
if [[ ! -f $PROJECT_DIR/README.md ]]; then
  echo "Error: README.md not found in $PROJECT_DIR"
  echo "Please run cc-start-day first."
  exit 1
fi

# Extract content from README
README_CONTENT=$(cat $PROJECT_DIR/README.md)
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to read README.md"
  exit 1
fi

# Check if log file exists, create if not
if [[ ! -f $LOG_FILE ]]; then
  echo "Creating new log file: $LOG_FILE"
  echo "# Week $WEEK_FORMATTED (Days $((($WEEK_IN_PHASE-1)*6+1))-$((($WEEK_IN_PHASE)*6)))" > $LOG_FILE
  echo "" >> $LOG_FILE
  echo "## Week Overview" >> $LOG_FILE
  echo "- **Focus**: " >> $LOG_FILE
  echo "- **Launch School Connection**: " >> $LOG_FILE
  echo "- **Weekly Goals**:" >> $LOG_FILE
  echo "  - " >> $LOG_FILE
  echo "  - " >> $LOG_FILE
  echo "  - " >> $LOG_FILE
  echo "" >> $LOG_FILE
  echo "## Daily Logs" >> $LOG_FILE
  echo "" >> $LOG_FILE
fi

# Append to log
echo "## Day $CURRENT_DAY" >> $LOG_FILE || { echo "Error: Failed to write to log file"; exit 1; }

# Extract sections from README
FOCUS_SECTION=$(echo "$README_CONTENT" | grep -A 10 "## Today's Focus" | grep -B 10 "## Launch School Connection" | grep -v "## Launch School Connection")
LS_SECTION=$(echo "$README_CONTENT" | grep -A 10 "## Launch School Connection" | grep -B 10 "## Progress Log" | grep -v "## Progress Log")
PROGRESS_SECTION=$(echo "$README_CONTENT" | grep -A 10 "## Progress Log" | grep -B 10 "## Reflections" | grep -v "## Reflections")
REFLECTIONS_SECTION=$(echo "$README_CONTENT" | grep -A 10 "## Reflections" | tail -n +2)

# Append to log with error checking
echo "$FOCUS_SECTION" >> $LOG_FILE || { echo "Error: Failed to append focus section to log"; exit 1; }
echo "$LS_SECTION" >> $LOG_FILE || { echo "Error: Failed to append Launch School section to log"; exit 1; }
echo "$PROGRESS_SECTION" >> $LOG_FILE || { echo "Error: Failed to append progress section to log"; exit 1; }
echo "### Reflections" >> $LOG_FILE || { echo "Error: Failed to append reflections header to log"; exit 1; }
echo "$REFLECTIONS_SECTION" >> $LOG_FILE || { echo "Error: Failed to append reflections to log"; exit 1; }
echo "" >> $LOG_FILE || { echo "Error: Failed to append newline to log"; exit 1; }

echo "Progress successfully logged to $LOG_FILE"
EOF

# Make the script executable
chmod +x ~/bin/cc-log-progress.sh || { echo "Error: Failed to make script executable"; exit 1; }

# Create cc-push-updates.sh in bin directory
echo "Creating cc-push-updates.sh..."
cat > ~/bin/cc-push-updates.sh << 'EOF'
#!/bin/zsh

# Check if day counter exists
if [[ ! -f ~/.cc-current-day ]]; then
  echo "Error: Day counter file not found. Run setup script first."
  exit 1
fi

# Get current day
CURRENT_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)
if [[ ! $CURRENT_DAY =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid day counter value: $CURRENT_DAY"
  exit 1
fi

# Base project directory
BASE_DIR=~/projects/6-7-coding-challenge
if [[ ! -d $BASE_DIR ]]; then
  echo "Error: Base project directory not found at $BASE_DIR"
  echo "Please run the setup script first."
  exit 1
fi

# Check if it's a git repository
if [[ ! -d "$BASE_DIR/.git" ]]; then
  echo "Error: Not a git repository. Please init git first."
  echo "cd $BASE_DIR && git init"
  exit 1
fi

# Move to the repository directory
cd $BASE_DIR || { echo "Error: Failed to change to project directory"; exit 1; }

# Check if there are any changes to commit
if git diff --quiet && git diff --staged --quiet; then
  echo "No changes to commit. Have you made any progress today?"
  read -p "Proceed anyway? (y/n): " proceed
  if [[ $proceed != "y" && $proceed != "Y" ]]; then
    echo "Operation canceled."
    exit 0
  fi
fi

# Get commit message with date
COMMIT_DATE=$(date +"%Y-%m-%d")
COMMIT_MSG="Day $CURRENT_DAY: $COMMIT_DATE"

# Additional commit details
PHASE=$((($CURRENT_DAY-1)/100+1))
WEEK_IN_PHASE=$((($CURRENT_DAY-1)%100/6+1))
WEEK_FORMATTED=$(printf "%02d" $WEEK_IN_PHASE)

# Determine phase name
case $PHASE in
  1) PHASE_NAME="Ruby Backend" ;;
  2) PHASE_NAME="Python Data Analysis" ;;
  3) PHASE_NAME="JavaScript Frontend" ;;
  4) PHASE_NAME="Full-Stack Projects" ;;
  5) PHASE_NAME="ML Finance Applications" ;;
  *) PHASE_NAME="Unknown Phase" ;;
esac

# Add project directory info to commit message
PROJECT_DIR=$BASE_DIR/phase${PHASE}_*/week$WEEK_FORMATTED/day$CURRENT_DAY
if [[ -d $PROJECT_DIR ]]; then
  # Extract focus from README
  README_PATH=$(find $PROJECT_DIR -name "README.md" | head -n 1)
  if [[ -f $README_PATH ]]; then
    PRIMARY_GOAL=$(grep -A 3 "## Today's Focus" $README_PATH | grep "Primary goal:" | sed 's/.*Primary goal: \(.*\)/\1/' || echo "")
    if [[ -n $PRIMARY_GOAL ]]; then
      COMMIT_MSG="$COMMIT_MSG - $PRIMARY_GOAL"
    fi
  fi
fi

# Add files to git
echo "Adding files to git..."
git add . || { echo "Error: Failed to add files to git"; exit 1; }

# Commit changes
echo "Committing changes with message: $COMMIT_MSG"
git commit -m "$COMMIT_MSG" || { echo "Warning: Git commit failed or nothing to commit"; }

# Check if remote exists
if git remote -v | grep -q origin; then
  echo "Pushing to remote repository..."
  git push origin main || { echo "Warning: Push to origin failed. You may need to push manually."; }
else
  echo "Warning: No remote 'origin' found. Set up a remote to push your progress."
  echo "git remote add origin YOUR_REPOSITORY_URL"
fi

# Increment day counter
echo "Incrementing day counter from $CURRENT_DAY to $((CURRENT_DAY + 1))..."
echo $((CURRENT_DAY + 1)) > ~/.cc-current-day || { echo "Error: Failed to update day counter"; exit 1; }

# Success message
echo "===================="
echo "Updates successfully pushed and day counter incremented"
echo "Current progress: Day $CURRENT_DAY/500 completed ($(( ($CURRENT_DAY-1) * 100 / 500 ))%)"
echo "Phase $PHASE: $PHASE_NAME"
echo "Tomorrow is Day $((CURRENT_DAY + 1))"
echo "===================="
EOF

# Make the script executable
chmod +x ~/bin/cc-push-updates.sh || { echo "Error: Failed to make script executable"; exit 1; }

# Create cc-status.sh in bin directory
echo "Creating cc-status.sh..."
cat > ~/bin/cc-status.sh << 'EOF'
#!/bin/zsh

# Check if day counter exists
if [[ ! -f ~/.cc-current-day ]]; then
  echo "Error: Day counter file not found. Run setup script first."
  exit 1
fi

# Get current day
CURRENT_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)
if [[ ! $CURRENT_DAY =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid day counter value: $CURRENT_DAY"
  exit 1
fi

TOTAL_DAYS=500
DAYS_REMAINING=$((TOTAL_DAYS - CURRENT_DAY + 1))
PERCENT_COMPLETE=$(( (CURRENT_DAY - 1) * 100 / TOTAL_DAYS ))

PHASE=$((($CURRENT_DAY-1)/100+1))
WEEK_IN_PHASE=$((($CURRENT_DAY-1)%100/6+1))
DAY_IN_WEEK=$(( ($CURRENT_DAY-1) % 6 + 1 ))
WEEK_OVERALL=$(( ($CURRENT_DAY-1) / 6 + 1 ))

# Determine phase name
case $PHASE in
  1) PHASE_NAME="Ruby Backend" ;;
  2) PHASE_NAME="Python Data Analysis" ;;
  3) PHASE_NAME="JavaScript Frontend" ;;
  4) PHASE_NAME="Full-Stack Projects" ;;
  5) PHASE_NAME="ML Finance Applications" ;;
  *) PHASE_NAME="Unknown Phase" ;;
esac

# Platform-compatible date calculation for completion date
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS
  COMPLETION_DATE=$(date -v+${DAYS_REMAINING}d +"%Y-%m-%d")
else
  # Linux/other Unix
  if command -v date &> /dev/null; then
    if date --version 2>&1 | grep -q GNU; then
      # GNU date (Linux)
      COMPLETION_DATE=$(date -d "+${DAYS_REMAINING} days" +"%Y-%m-%d")
    else
      # Try simple calculation as fallback
      CURRENT_TIMESTAMP=$(date +%s)
      COMPLETION_TIMESTAMP=$((CURRENT_TIMESTAMP + DAYS_REMAINING * 86400))
      COMPLETION_DATE=$(date -r $COMPLETION_TIMESTAMP +"%Y-%m-%d" 2>/dev/null || echo "Unknown (date calculation not supported)")
    fi
  else
    COMPLETION_DATE="Unknown (date command not found)"
  fi
fi

# Calculate time elapsed and remaining
START_DATE="2025-04-01" # Challenge start date
CURRENT_DATE=$(date +"%Y-%m-%d")

if command -v date &> /dev/null; then
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    START_SECONDS=$(date -j -f "%Y-%m-%d" "$START_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "2025-04-01" +%s)
    CURRENT_SECONDS=$(date -j -f "%Y-%m-%d" "$CURRENT_DATE" +%s)
  else
    # Linux/GNU date
    START_SECONDS=$(date -d "$START_DATE" +%s 2>/dev/null || date -d "2025-04-01" +%s)
    CURRENT_SECONDS=$(date -d "$CURRENT_DATE" +%s)
  fi
  
  DAYS_ELAPSED=$(( (CURRENT_SECONDS - START_SECONDS) / 86400 ))
  
  # Adjust for Sundays (don't count them in the challenge)
  WEEKS_ELAPSED=$(( DAYS_ELAPSED / 7 ))
  SUNDAYS_ELAPSED=$WEEKS_ELAPSED
  ACTUAL_DAYS_ELAPSED=$(( DAYS_ELAPSED - SUNDAYS_ELAPSED ))
  
  # Calculate expected day vs actual day
  EXPECTED_DAY=$((ACTUAL_DAYS_ELAPSED + 1))
  DAY_DIFFERENCE=$((CURRENT_DAY - EXPECTED_DAY))
  
  if [[ $DAY_DIFFERENCE -gt 0 ]]; then
    DAY_STATUS="Ahead of schedule by $DAY_DIFFERENCE day(s)"
  elif [[ $DAY_DIFFERENCE -lt 0 ]]; then
    DAY_STATUS="Behind schedule by $(( -1 * DAY_DIFFERENCE )) day(s)"
  else
    DAY_STATUS="On schedule"
  fi
else
  DAYS_ELAPSED="Unknown"
  DAY_STATUS="Status calculation not supported"
fi

# Print status with colorized output
if command -v tput &> /dev/null; then
  BOLD=$(tput bold)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  MAGENTA=$(tput setaf 5)
  CYAN=$(tput setaf 6)
  RESET=$(tput sgr0)
else
  BOLD=""
  GREEN=""
  YELLOW=""
  BLUE=""
  MAGENTA=""
  CYAN=""
  RESET=""
fi

echo "${BOLD}╔═══════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}║            6/7 CODING CHALLENGE STATUS             ║${RESET}"
echo "${BOLD}╠═══════════════════════════════════════════════════╣${RESET}"
printf "${BOLD}║${RESET} ${GREEN}Current Day:${RESET} %-37s ${BOLD}║${RESET}\n" "$CURRENT_DAY/500"
printf "${BOLD}║${RESET} ${BLUE}Phase:${RESET} %-43s ${BOLD}║${RESET}\n" "$PHASE of 5 - $PHASE_NAME"
printf "${BOLD}║${RESET} ${MAGENTA}Week:${RESET} %-44s ${BOLD}║${RESET}\n" "$WEEK_OVERALL overall (Week $WEEK_IN_PHASE in Phase $PHASE)"
printf "${BOLD}║${RESET} ${CYAN}Day of Week:${RESET} %-37s ${BOLD}║${RESET}\n" "$DAY_IN_WEEK/6"
printf "${BOLD}║${RESET} ${YELLOW}Progress:${RESET} %-40s ${BOLD}║${RESET}\n" "$PERCENT_COMPLETE% complete"
printf "${BOLD}║${RESET} ${GREEN}Days Elapsed:${RESET} %-35s ${BOLD}║${RESET}\n" "$DAYS_ELAPSED"
printf "${BOLD}║${RESET} ${GREEN}Schedule Status:${RESET} %-32s ${BOLD}║${RESET}\n" "$DAY_STATUS"
printf "${BOLD}║${RESET} ${BLUE}Days Remaining:${RESET} %-34s ${BOLD}║${RESET}\n" "$DAYS_REMAINING"
printf "${BOLD}║${RESET} ${MAGENTA}Estimated Completion:${RESET} %-29s ${BOLD}║${RESET}\n" "$COMPLETION_DATE"

# Calculate and display streaks
BASE_DIR=~/projects/6-7-coding-challenge
if [[ -d $BASE_DIR/.git ]]; then
  # Get current streak (consecutive days with commits)
  cd $BASE_DIR
  CURRENT_STREAK=0
  YESTERDAY=$(date -v-1d +"%Y-%m-%d" 2>/dev/null || date -d "yesterday" +"%Y-%m-%d" 2>/dev/null || echo "")
  
  if [[ -n $YESTERDAY ]]; then
    while git log --since="$YESTERDAY" --until="$YESTERDAY 23:59:59" --pretty=format:%H | grep -q .; do
      CURRENT_STREAK=$((CURRENT_STREAK + 1))
      YESTERDAY=$(date -v-${CURRENT_STREAK}d +"%Y-%m-%d" 2>/dev/null || date -d "${CURRENT_STREAK} days ago" +"%Y-%m-%d" 2>/dev/null || break)
      # Skip Sundays in streak calculation
      DAY_OF_WEEK=$(date -j -f "%Y-%m-%d" "$YESTERDAY" +%u 2>/dev/null || date -d "$YESTERDAY" +%u 2>/dev/null || echo "0")
      if [[ $DAY_OF_WEEK -eq 7 ]]; then
        YESTERDAY=$(date -v-$((CURRENT_STREAK + 1))d +"%Y-%m-%d" 2>/dev/null || date -d "$((CURRENT_STREAK + 1)) days ago" +"%Y-%m-%d" 2>/dev/null || break)
      fi
    done
    
    printf "${BOLD}║${RESET} ${CYAN}Current Streak:${RESET} %-34s ${BOLD}║${RESET}\n" "$CURRENT_STREAK day(s)"
  fi
fi

# Add repository information
if [[ -d $BASE_DIR/.git ]]; then
  cd $BASE_DIR
  BRANCH=$(git branch --show-current 2>/dev/null || echo "Unknown")
  LAST_COMMIT=$(git log -1 --pretty=format:"%h - %s" 2>/dev/null || echo "No commits yet")
  LAST_COMMIT_DATE=$(git log -1 --pretty=format:"%cd" --date=short 2>/dev/null || echo "N/A")
  
  echo "${BOLD}╠═══════════════════════════════════════════════════╣${RESET}"
  printf "${BOLD}║${RESET} ${YELLOW}Active Branch:${RESET} %-35s ${BOLD}║${RESET}\n" "$BRANCH"
  printf "${BOLD}║${RESET} ${GREEN}Last Commit:${RESET} %-37s ${BOLD}║${RESET}\n" "$LAST_COMMIT"
  printf "${BOLD}║${RESET} ${BLUE}Commit Date:${RESET} %-36s ${BOLD}║${RESET}\n" "$LAST_COMMIT_DATE"
fi

echo "${BOLD}╚═══════════════════════════════════════════════════╝${RESET}"
EOF

# Make the script executable
chmod +x ~/bin/cc-status.sh || { echo "Error: Failed to make script executable"; exit 1; }

# Initialize day counter
echo "Initializing day counter to 1..."
echo "1" > ~/.cc-current-day || { echo "Error: Failed to initialize day counter"; exit 1; }

# Create initial directory structure
echo "Creating directory structure..."
BASE_DIR=~/projects/6-7-coding-challenge
mkdir -p $BASE_DIR/{logs,phase1_ruby,phase2_python,phase3_javascript,phase4_fullstack,phase5_ml_finance} || { 
  echo "Error: Failed to create project directories"; 
  exit 1; 
}

# Create log directories for phase 1
mkdir -p $BASE_DIR/logs/phase1 || { echo "Error: Failed to create log directories"; exit 1; }

# Create week directories for phase 1
for i in {01..17}; do 
  mkdir -p $BASE_DIR/phase1_ruby/week$i || { echo "Error: Failed to create week directory: week$i"; exit 1; }
done

# Initialize git repository if it doesn't exist
if [[ ! -d "$BASE_DIR/.git" ]]; then
  echo "Initializing git repository..."
  cd $BASE_DIR || { echo "Error: Failed to change to project directory"; exit 1; }
  git init || { echo "Error: Failed to initialize git repository"; exit 1; }
  
  # Create initial .gitignore
  cat > $BASE_DIR/.gitignore << 'GIT_IGNORE'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
*~

# Environment files
.env
.env.local

# Language specific
*.gem
*.rbc
__pycache__/
*.py[cod]
node_modules/
GIT_IGNORE

  # Initial commit
  git add . || { echo "Error: Failed to add files to git"; exit 1; }
  git commit -m "Initial 6/7 Coding Challenge setup" || { echo "Warning: Initial commit failed"; }
  
  echo "Git repository initialized with initial commit."
  echo "Remember to add a remote with:"
  echo "git remote add origin YOUR_REPOSITORY_URL"
fi

# Add aliases to .zshrc if they don't exist
if ! grep -q "# 6/7 Coding Challenge aliases" ~/.zshrc; then
  echo "Adding aliases to .zshrc..."
  cat >> ~/.zshrc << 'EOF'

# 6/7 Coding Challenge aliases
alias ccstart="~/bin/cc-start-day.sh"
alias cclog="~/bin/cc-log-progress.sh"
alias ccpush="~/bin/cc-push-updates.sh"
alias ccstatus="~/bin/cc-status.sh"
EOF
  if [[ $? -ne 0 ]]; then
    echo "Warning: Failed to add aliases to .zshrc. You'll need to add them manually."
  else
    echo "Aliases added to .zshrc."
  fi
else
  echo "Aliases already exist in .zshrc."
fi

# Show setup completion message
echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║       6/7 CODING CHALLENGE SETUP COMPLETE          ║"
echo "╠═══════════════════════════════════════════════════╣"
echo "║ Your 6/7 Coding Challenge environment is ready:    ║"
echo "║                                                   ║"
echo "║ • Scripts installed to ~/bin/                      ║"
echo "║ • Project structure created at:                    ║"
echo "║   ~/projects/6-7-coding-challenge/                 ║"
echo "║ • Day counter initialized to 1                     ║"
echo "║ • Git repository initialized                       ║"
echo "║                                                   ║"
echo "║ Commands available:                                ║"
echo "║   ccstart  - Start the day's coding session        ║"
echo "║   cclog    - Log progress to weekly log file       ║"
echo "║   ccpush   - Commit and push changes               ║"
echo "║   ccstatus - Show challenge progress               ║"
echo "║                                                   ║"
echo "╠═══════════════════════════════════════════════════╣"
echo "║ To begin:                                          ║"
echo "║ 1. Source your .zshrc:                             ║"
echo "║    source ~/.zshrc                                 ║"
echo "║ 2. Start your first day:                           ║"
echo "║    ccstart                                         ║"
echo "╚═══════════════════════════════════════════════════╝" Primary goal: 
- [ ] Secondary goal:
- [ ]