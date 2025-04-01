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
