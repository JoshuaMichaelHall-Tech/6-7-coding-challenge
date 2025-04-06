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
