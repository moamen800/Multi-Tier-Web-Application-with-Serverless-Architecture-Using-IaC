#!/bin/bash

URL="http://d3d3vf2ocqssr3.cloudfront.net/"
TOTAL_REQUESTS=500
BLOCK_COUNT=0
MAX_PARALLEL=10                # Number of parallel "threads"
DELAY_BETWEEN_REQUESTS=0.2     # Delay in seconds

RED='\033[0;31m'
NC='\033[0m' # No Color

start_time=$(date +%s.%N)     # Start time measurement

# Clean up previous results
rm -f blocked.txt first_block_detected.flag

# Function to send a single request
send_request() {
  local i=$1
  local FULL_URL="$URL?nocache=$(date +%s%N)"
  
  STATUS_CODE=$(curl --max-time 5 -s -o /dev/null -w "%{http_code}" -H "User-Agent: WAF-Test-Script" "$FULL_URL")

  if [ -z "$STATUS_CODE" ]; then
    echo "Request $i: No response (timeout)"
  else
    echo "Request $i: Status Code = $STATUS_CODE"
    if [ "$STATUS_CODE" -eq 403 ]; then
      echo -e "${RED}🚫 Blocked by WAF (403)${NC}"
      echo "403" >> blocked.txt

      # Check if the first_block_detected.flag file exists
      if [ ! -f first_block_detected.flag ]; then
        first_block_time=$(date +%s.%N)
        time_diff=$(echo "$first_block_time - $start_time" | bc)
        echo "$time_diff" > first_block_detected.flag
        echo -e "${RED}⚡ First block detected after $time_diff seconds!${NC}"
      fi
    fi
  fi

  # Delay after each request
  sleep $DELAY_BETWEEN_REQUESTS
}

# Send requests in parallel with delay
for ((i=1; i<=TOTAL_REQUESTS; i++))
do
  send_request $i &  # Run in background
  
  # Limit number of parallel jobs
  if (( i % MAX_PARALLEL == 0 )); then
    wait  # Wait for the batch to finish
  fi
done

# Wait for any remaining background jobs to finish
wait

# Calculate how many were blocked
if [ -f blocked.txt ]; then
  BLOCK_COUNT=$(wc -l < blocked.txt)
else
  BLOCK_COUNT=0
fi

echo -e "\nSummary: Sent $TOTAL_REQUESTS requests, Blocked: $BLOCK_COUNT"

# Show final first block time if it was detected
if [ -f first_block_detected.flag ]; then
  FIRST_TIME=$(cat first_block_detected.flag)
  echo -e "⏱️ First block detected after $FIRST_TIME seconds (confirmed)"
else
  echo -e "✅ No blocking happened during this test."
fi

# Clean up
rm -f blocked.txt first_block_detected.flag
