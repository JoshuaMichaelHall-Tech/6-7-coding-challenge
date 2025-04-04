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
