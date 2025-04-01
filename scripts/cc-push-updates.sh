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
