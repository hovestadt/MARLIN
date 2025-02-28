#!/bin/bash

# Run inside calls.sort.bam folder

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$0")
echo $SCRIPT_DIR

# Check for new bam files every 5 seconds
while true; do
	ls -1 | grep ".bam$\|.pred.pdf$" | sed 's/.pred.pdf$//' | uniq -c | awk '{if($1==1){print $2}}' | xargs -I {} bash $SCRIPT_DIR/1_process_live.sh {}
	echo `date`: Waiting for new files
	sleep 5
done
