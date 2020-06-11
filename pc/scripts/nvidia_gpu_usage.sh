PERCENTAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv | grep -o '[0-9]*')
echo "$PERCENTAGE%"
