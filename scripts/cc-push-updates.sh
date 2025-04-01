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
