PID_FILE=/var/run/process-bulk-uploads.pid

if [ -e $PID_FILE ]; then
  echo "script is already running"
  exit
fi

# Ensure PID file is removed on program exit.
trap "rm -f -- '$PID_FILE'" EXIT

# Create a file with current PID to indicate that process is running.
echo $$ > "$PID_FILE"

/usr/bin/node /root/treetracker-pipeline-cron/process-bulk-uploads.js >> /var/log/process-bulk-uploads.log 2>/var/log/process-bulk-uploads.log
