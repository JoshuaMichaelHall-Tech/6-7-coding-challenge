#!/bin/zsh

# 6/7 Coding Challenge Setup/Update/Uninstall Script
# This script provides a complete solution for managing the 6/7 Coding Challenge environment

# Constants
SCRIPT_VERSION="2.0.0"
BASE_DIR=~/projects/6-7-coding-challenge
BIN_DIR=~/bin
CONFIG_FILE=~/.cc-config
DAY_COUNTER=~/.cc-current-day
ALIASES_MARKER="# 6/7 Coding Challenge aliases"
ALIASES_BLOCK="
$ALIASES_MARKER
alias ccstart=\"$BIN_DIR/cc-start-day.sh\"
alias cclog=\"$BIN_DIR/cc-log-progress.sh\"
alias ccpush=\"$BIN_DIR/cc-push-updates.sh\"
alias ccstatus=\"$BIN_DIR/cc-status.sh\"
alias ccupdate=\"$BIN_DIR/cc-update.sh\"
alias ccuninstall=\"$BIN_DIR/cc-uninstall.sh\"
"

# Colors and formatting
if command -v tput &> /dev/null; then
  BOLD=$(tput bold)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1)
  BLUE=$(tput setaf 4)
  RESET=$(tput sgr0)
else
  BOLD=""
  GREEN=""
  YELLOW=""
  RED=""
  BLUE=""
  RESET=""
fi

# Function to print section headers
print_header() {
  echo "${BOLD}${BLUE}=== $1 ===${RESET}"
}

# Function to print success messages
print_success() {
  echo "${GREEN}✓ $1${RESET}"
}

# Function to print warning messages
print_warning() {
  echo "${YELLOW}⚠ $1${RESET}"
}

# Function to print error messages
print_error() {
  echo "${RED}✗ $1${RESET}"
}

# Function to print info messages
print_info() {
  echo "${BLUE}ℹ $1${RESET}"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to check if aliases are already installed
aliases_installed() {
  grep -q "$ALIASES_MARKER" ~/.zshrc 2>/dev/null
  return $?
}

# Function to check if scripts are installed
scripts_installed() {
  [[ -f "$BIN_DIR/cc-start-day.sh" && -f "$BIN_DIR/cc-log-progress.sh" && \
     -f "$BIN_DIR/cc-push-updates.sh" && -f "$BIN_DIR/cc-status.sh" ]]
  return $?
}

# Check if program is already installed
check_installed() {
  local is_installed=false
  
  if [[ -f "$CONFIG_FILE" ]]; then
    is_installed=true
    current_version=$(grep "version=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2)
    print_info "6/7 Coding Challenge is already installed (version $current_version)."
  fi
  
  if scripts_installed; then
    is_installed=true
    print_info "Scripts are installed in $BIN_DIR."
  fi
  
  if aliases_installed; then
    is_installed=true
    print_info "Aliases are configured in ~/.zshrc."
  fi
  
  if [[ -f "$DAY_COUNTER" ]]; then
    is_installed=true
    CURRENT_DAY=$(cat "$DAY_COUNTER" 2>/dev/null || echo "invalid")
    print_info "Day counter is set to $CURRENT_DAY."
  fi
  
  if [[ -d "$BASE_DIR" ]]; then
    is_installed=true
    print_info "Project directory exists at $BASE_DIR."
  fi
  
  if $is_installed; then
    echo ""
    echo "It looks like 6/7 Coding Challenge is already installed."
    echo "What would you like to do?"
    echo ""
    echo "1) Update to the latest version"
    echo "2) Reinstall from scratch"
    echo "3) Uninstall completely"
    echo "4) Exit"
    echo ""
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
      1)
        print_header "Updating 6/7 Coding Challenge"
        return 2  # Update
        ;;
      2)
        print_header "Reinstalling 6/7 Coding Challenge"
        return 0  # Install
        ;;
      3)
        print_header "Uninstalling 6/7 Coding Challenge"
        return 1  # Uninstall
        ;;
      4|*)
        print_info "Exiting..."
        exit 0
        ;;
    esac
  else
    return 0  # Not installed, proceed with install
  fi
}

# Function to check prerequisites
check_prerequisites() {
  print_header "Checking Prerequisites"
  
  local prereqs_ok=true
  
  # Check for zsh
  if [[ "$SHELL" != *"zsh"* ]]; then
    print_warning "Current shell is not zsh. Some features may not work correctly."
    prereqs_ok=false
  else
    print_success "zsh is your current shell."
  fi
  
  # Check for git
  if ! command_exists git; then
    print_error "git is not installed. Please install git first."
    prereqs_ok=false
  else
    print_success "git is installed ($(git --version | cut -d' ' -f3))."
  fi
  
  # Check for tmux (optional but recommended)
  if ! command_exists tmux; then
    print_warning "tmux is not installed. It's recommended for the best experience."
    print_info "For macOS: brew install tmux"
    print_info "For Ubuntu/Debian: sudo apt install tmux"
    print_info "For Fedora/RHEL: sudo dnf install tmux"
  else
    print_success "tmux is installed ($(tmux -V | cut -d' ' -f2))."
  fi
  
  # Check for editor (nvim or vim)
  if command_exists nvim; then
    print_success "neovim is installed."
  elif command_exists vim; then
    print_success "vim is installed."
  else
    print_warning "Neither neovim nor vim is installed. A text editor is recommended."
  fi
  
  # Check for Ruby (for Phase 1)
  if command_exists ruby; then
    print_success "Ruby is installed ($(ruby -v | cut -d' ' -f2))."
  else
    print_warning "Ruby is not installed. It will be needed for Phase 1."
  fi
  
  # Check for ~/bin directory
  if [[ ! -d "$BIN_DIR" ]]; then
    print_info "~/bin directory does not exist. It will be created."
  else
    print_success "~/bin directory exists."
  fi
  
  # Check if ~/bin is in PATH
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    print_warning "~/bin is not in your PATH. We'll add it to your .zshrc"
  else
    print_success "~/bin is in your PATH."
  fi
  
  return $prereqs_ok
}

# Function to install or update the configuration file
setup_config_file() {
  print_header "Setting up Configuration File"
  
  # Create or update config file
  if [[ -f "$CONFIG_FILE" ]]; then
    print_info "Updating existing configuration file."
    # Preserve existing settings while adding new ones
    local current_version=$(grep "version=" "$CONFIG_FILE" | cut -d'=' -f2)
    if [[ "$current_version" != "$SCRIPT_VERSION" ]]; then
      sed -i.bak "s/version=.*/version=$SCRIPT_VERSION/" "$CONFIG_FILE" 2>/dev/null || \
        sed "s/version=.*/version=$SCRIPT_VERSION/" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
      sed -i.bak "s/last_updated=.*/last_updated=$(date +"%Y-%m-%d")/" "$CONFIG_FILE" 2>/dev/null || \
        sed "s/last_updated=.*/last_updated=$(date +"%Y-%m-%d")/" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
      print_success "Updated version from $current_version to $SCRIPT_VERSION."
    else
      print_info "Configuration is already at version $SCRIPT_VERSION."
    fi
  else
    print_info "Creating new configuration file."
    cat > "$CONFIG_FILE" << EOF
# 6/7 Coding Challenge Configuration
version=$SCRIPT_VERSION
install_date=$(date +"%Y-%m-%d")
last_updated=$(date +"%Y-%m-%d")
EOF
    print_success "Configuration file created."
  fi
}

# Function to set up scripts directory
setup_bin_directory() {
  print_header "Setting up Scripts Directory"
  
  # Create bin directory if it doesn't exist
  if [[ ! -d "$BIN_DIR" ]]; then
    mkdir -p "$BIN_DIR"
    print_success "Created ~/bin directory."
  else
    print_info "~/bin directory already exists."
  fi
  
  # Add bin to PATH if needed
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    print_success "Added ~/bin to PATH in .zshrc."
  fi
}

# Function to create or update script files
install_scripts() {
  print_header "Installing/Updating Scripts"
  
  # Backup existing scripts if they exist
  if scripts_installed; then
    print_info "Backing up existing scripts..."
    BACKUP_DIR="$BIN_DIR/cc-backup-$(date +%Y%m%d%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp "$BIN_DIR/cc-"*.sh "$BACKUP_DIR/" 2>/dev/null
    print_success "Existing scripts backed up to $BACKUP_DIR."
  fi
  
  # Install updated scripts
  print_info "Installing cc-start-day.sh..."
  cat > "$BIN_DIR/cc-start-day.sh" << 'EOF'
#!/bin/zsh

# Get current day
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

# Set up the day's work if README doesn't exist
if [[ ! -f $PROJECT_DIR/README.md ]]; then
  echo "Setting up Day $CURRENT_DAY (Phase $PHASE, Week $WEEK_FORMATTED)"
  cat > $PROJECT_DIR/README.md << EOF
# Day $CURRENT_DAY - Phase $PHASE (Week $WEEK_FORMATTED)

## Today's Focus
- [ ] Primary goal: 
- [ ] Secondary goal:
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
  echo "Warning: tmux is not installed. Opening project directory without tmux."
  # Set editor (default to vim if nvim is not available)
  if command -v nvim &> /dev/null; then
    EDITOR="nvim"
  elif command -v vim &> /dev/null; then
    EDITOR="vim"
  else
    EDITOR="${EDITOR:-vi}"
  fi
  
  # Open the directory and file without tmux
  cd $PROJECT_DIR
  $EDITOR README.md
  exit 0
fi

# Set editor (default to vim if nvim is not available)
if command -v nvim &> /dev/null; then
  EDITOR="nvim"
else
  EDITOR="vim"
fi

# Kill existing session if it exists
if tmux has-session -t coding-challenge 2>/dev/null; then
  echo "Existing session found. Killing it..."
  tmux kill-session -t coding-challenge
fi

# Create a new tmux session
echo "Starting tmux session..."
cd $PROJECT_DIR || { echo "Error: Failed to change to project directory"; exit 1; }

# Create a detached session
tmux new-session -d -s coding-challenge -c "$PROJECT_DIR"

# Split the window
tmux split-window -v -p 30 -t coding-challenge -c "$PROJECT_DIR"

# Send commands to the panes
tmux send-keys -t coding-challenge:0.0 "clear" C-m
tmux send-keys -t coding-challenge:0.1 "$EDITOR README.md" C-m

# Attach to the session
exec tmux attach-session -t coding-challenge
EOF
  
  print_info "Installing cc-log-progress.sh..."
  cat > "$BIN_DIR/cc-log-progress.sh" << 'EOF'
#!/bin/zsh

# Check if a specific day was requested
if [[ $1 =~ ^[0-9]+$ ]]; then
  LOG_DAY=$1
  echo "Logging for specified day: $LOG_DAY"
else
  # If no day specified, use current day counter
  if [[ ! -f ~/.cc-current-day ]]; then
    echo "Error: Day counter file not found. Run setup script first."
    exit 1
  fi
  LOG_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)
  echo "Logging for current day: $LOG_DAY"
fi

# Validate the day number
if [[ $LOG_DAY -lt 1 ]]; then
  echo "Error: Invalid day number. Days start from 1."
  exit 1
fi

CURRENT_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)
if [[ $LOG_DAY -gt $CURRENT_DAY ]]; then
  echo "Error: Cannot log for future days. Current day is $CURRENT_DAY."
  exit 1
fi

# Calculate phase, week based on the day to log
PHASE=$((($LOG_DAY-1)/100+1))
WEEK_IN_PHASE=$((($LOG_DAY-1)%100/6+1))

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

PROJECT_DIR=$BASE_DIR/$PHASE_DIR/week$WEEK_FORMATTED/day$LOG_DAY
LOG_FILE=$BASE_DIR/logs/phase$PHASE/week$WEEK_FORMATTED.md

# Check if project directory exists
if [[ ! -d $PROJECT_DIR ]]; then
  echo "Error: Project directory not found at $PROJECT_DIR"
  echo "Please make sure you've initialized this day with cc-start-day."
  exit 1
fi

# Check if README exists
if [[ ! -f $PROJECT_DIR/README.md ]]; then
  echo "Error: README.md not found in $PROJECT_DIR"
  echo "Please make sure you've initialized this day with cc-start-day."
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
  mkdir -p $(dirname $LOG_FILE) || { echo "Error: Failed to create log directory"; exit 1; }
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

# Check if day entry already exists
if grep -q "## Day $LOG_DAY" "$LOG_FILE"; then
  echo "Warning: An entry for Day $LOG_DAY already exists in the log file."
  read -p "Do you want to replace it? (y/n): " replace_entry
  if [[ $replace_entry != "y" && $replace_entry != "Y" ]]; then
    echo "Operation canceled."
    exit 0
  fi
  
  # Remove the existing entry for this day (with newlines and all content until next day or EOF)
  # This uses awk to find the start of the day section, then delete until it finds another day section or EOF
  TMP_FILE=$(mktemp)
  awk -v day="## Day $LOG_DAY" 'BEGIN{skip=0} 
    /^## Day [0-9]+$/ && $0 != day {skip=0} 
    $0 == day {skip=1; next} 
    !skip {print}' "$LOG_FILE" > "$TMP_FILE"
  
  # Move the edited file back
  mv "$TMP_FILE" "$LOG_FILE"
  echo "Removed existing entry for Day $LOG_DAY"
fi

# Find the right spot to insert the new entry (entries should be in chronological order)
TMP_FILE=$(mktemp)
awk -v day=$LOG_DAY '
  BEGIN { inserted=0 }
  /^## Day ([0-9]+)$/ {
    if (inserted == 0) {
      day_num = $3 + 0; # Convert to number
      if (day < day_num) {
        print "## Day " day;
        inserted=1;
        print $0;
        next;
      }
    }
  }
  # If we reach EOF and haven't inserted, add it at the end
  END {
    if (inserted == 0) {
      print "## Day " day;
    }
  }
  { print }
' "$LOG_FILE" > "$TMP_FILE"

# If we didn't insert in the middle (awk END block ran), then the entry should be at the end
if ! grep -q "## Day $LOG_DAY" "$TMP_FILE"; then
  echo "## Day $LOG_DAY" >> "$LOG_FILE"
else
  # Otherwise, update the original file with the new order
  mv "$TMP_FILE" "$LOG_FILE"
fi

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

echo "Progress for Day $LOG_DAY successfully logged to $LOG_FILE"
EOF
  
  print_info "Installing cc-push-updates.sh..."
  cat > "$BIN_DIR/cc-push-updates.sh" << 'EOF'
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
  
  print_info "Installing cc-status.sh..."
  cat > "$BIN_DIR/cc-status.sh" << 'EOF'
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
      COMPLETION_DATE=$(date -r $COMPLETION_TIMESTAMP +"%Y-%m-%