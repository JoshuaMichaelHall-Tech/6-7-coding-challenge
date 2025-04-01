#!/bin/zsh

# Get current phase, week, and day
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
esac

# Create directories if needed
PROJECT_DIR=~/projects/6-7-coding-challenge/$PHASE_DIR/week$WEEK_FORMATTED/day$CURRENT_DAY
mkdir -p $PROJECT_DIR
mkdir -p ~/projects/6-7-coding-challenge/logs/phase$PHASE

# Initialize log file if needed
LOG_FILE=~/projects/6-7-coding-challenge/logs/phase$PHASE/week$WEEK_FORMATTED.md
if [[ ! -f $LOG_FILE ]]; then
  echo "# Week $WEEK_FORMATTED (Days $((($WEEK_IN_PHASE-1)*6+1))-$((($WEEK_IN_PHASE)*6)))\n" > $LOG_FILE
fi

# Set up the day's work
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

echo "Session started for Day $CURRENT_DAY in $PROJECT_DIR"