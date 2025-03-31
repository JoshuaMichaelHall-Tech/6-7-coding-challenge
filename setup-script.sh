#!/bin/zsh

# 6/7 Coding Challenge Setup Script
# This script sets up the environment for the 6/7 coding challenge

echo "Setting up your 6/7 Coding Challenge environment..."

# Create bin directory if it doesn't exist
if [[ ! -d ~/bin ]]; then
  echo "Creating ~/bin directory..."
  mkdir -p ~/bin
fi

# Copy scripts to bin directory
echo "Installing challenge scripts..."

# Create cc-start-day.sh
cat > ~/bin/cc-start-day.sh << 'EOF'
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

# Open tmux session
tmux new-session -d -s coding-challenge -n "code"
tmux split-window -v -p 30 -t coding-challenge
tmux send-keys -t coding-challenge:0.0 "cd $PROJECT_DIR && clear" C-m
tmux send-keys -t coding-challenge:0.1 "cd $PROJECT_DIR && nvim README.md" C-m
tmux attach-session -t coding-challenge

echo "Session started for Day $CURRENT_DAY in $PROJECT_DIR"
EOF

# Make the script executable
chmod +x ~/bin/cc-start-day.sh

# Create cc-log-progress.sh
cat > ~/bin/cc-log-progress.sh << 'EOF'
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
EOF

# Make the script executable
chmod +x ~/bin/cc-log-progress.sh

# Create cc-push-updates.sh
cat > ~/bin/cc-push-updates.sh << 'EOF'
#!/bin/zsh

# Get current day
CURRENT_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)

# Push changes to GitHub
cd ~/projects/6-7-coding-challenge
git add .
git commit -m "Day $CURRENT_DAY: $(date +"%Y-%m-%d")"
git push origin main

# Increment day counter
echo $((CURRENT_DAY + 1)) > ~/.cc-current-day

echo "Updates pushed and day counter incremented to $(cat ~/.cc-current-day)"
echo "Remember: Tomorrow is Day $(cat ~/.cc-current-day)"
EOF

# Make the script executable
chmod +x ~/bin/cc-push-updates.sh

# Create cc-status.sh
cat > ~/bin/cc-status.sh << 'EOF'
#!/bin/zsh

# Get current day
CURRENT_DAY=$(cat ~/.cc-current-day 2>/dev/null || echo 1)
TOTAL_DAYS=500
DAYS_REMAINING=$((TOTAL_DAYS - CURRENT_DAY + 1))
PERCENT_COMPLETE=$(( (CURRENT_DAY - 1) * 100 / TOTAL_DAYS ))

PHASE=$((($CURRENT_DAY-1)/100+1))
WEEK_IN_PHASE=$((($CURRENT_DAY-1)%100/6+1))
DAY_IN_WEEK=$(( ($CURRENT_DAY-1) % 6 + 1 ))
WEEK_OVERALL=$(( ($CURRENT_DAY-1) / 6 + 1 ))

# Print status
echo "╔═══════════════════════════════════════════════════╗"
echo "║            6/7 CODING CHALLENGE STATUS             ║"
echo "╠═══════════════════════════════════════════════════╣"
printf "║ Current Day: %-37s ║\n" "$CURRENT_DAY/500"
printf "║ Phase: %-43s ║\n" "$PHASE of 5"
printf "║ Week: %-44s ║\n" "$WEEK_OVERALL overall (Week $WEEK_IN_PHASE in Phase $PHASE)"
printf "║ Day of Week: %-37s ║\n" "$DAY_IN_WEEK/6"
printf "║ Progress: %-40s ║\n" "$PERCENT_COMPLETE% complete"
printf "║ Days Remaining: %-34s ║\n" "$DAYS_REMAINING"
printf "║ Estimated Completion: %-29s ║\n" "$(date -v+${DAYS_REMAINING}d +"%Y-%m-%d")"
echo "╚═══════════════════════════════════════════════════╝"
EOF

# Make the script executable
chmod +x ~/bin/cc-status.sh

# Initialize day counter
echo "1" > ~/.cc-current-day

# Create initial directory structure
echo "Creating directory structure..."
mkdir -p ~/projects/6-7-coding-challenge/{logs,phase1_ruby,phase2_python,phase3_javascript,phase4_fullstack,phase5_ml_finance}

# Create log directories for phase 1
mkdir -p ~/projects/6-7-coding-challenge/logs/phase1

# Create week directories for phase 1
for i in {01..17}; do 
  mkdir -p ~/projects/6-7-coding-challenge/phase1_ruby/week$i
done

# Create aliases for .zshrc if they don't exist
if ! grep -q "# 6/7 Coding Challenge aliases" ~/.zshrc; then
  echo "Adding aliases to .zshrc..."
  cat >> ~/.zshrc << 'EOF'

# 6/7 Coding Challenge aliases
alias ccstart="~/bin/cc-start-day.sh"
alias cclog="~/bin/cc-log-progress.sh"
alias ccpush="~/bin/cc-push-updates.sh"
alias ccstatus="~/bin/cc-status.sh"
EOF
fi

echo "Setup complete! Your 6/7 Coding Challenge environment is ready."
echo "Start your first day with: ccstart"
echo ""
echo "Don't forget to source your .zshrc or restart your terminal:"
echo "source ~/.zshrc"