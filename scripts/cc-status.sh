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
