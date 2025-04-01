#!/bin/zsh

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
esac

PROJECT_DIR=~/projects/6-7-coding-challenge/$PHASE_DIR/week$WEEK_FORMATTED/day$CURRENT_DAY
LOG_FILE=~/projects/6-7-coding-challenge/logs/phase$PHASE/week$WEEK_FORMATTED.md

# Extract content from README
README_CONTENT=$(cat $PROJECT_DIR/README.md)

# Append to log
echo "## Day $CURRENT_DAY" >> $LOG_FILE
echo "$(echo "$README_CONTENT" | grep -A 100 "## Today's Focus" | grep -A 100 "## Progress Log" | grep -B 100 "## Reflections" | grep -v "## Progress Log" | grep -v "## Reflections")" >> $LOG_FILE
echo "### Reflections" >> $LOG_FILE
echo "$(echo "$README_CONTENT" | grep -A 100 "## Reflections" | tail -n +2)" >> $LOG_FILE
echo "" >> $LOG_FILE

echo "Progress logged to $LOG_FILE"
