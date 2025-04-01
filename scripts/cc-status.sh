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
