set -e

# Copy the ssh key to a non-root directory
if [[ ! -e "/ssh/id_rsa" ]];then
 if [ ! -f "$SSH_KEY" ]; then
  echo "SSH key file not found at: $SSH_KEY"
  exit 1
 fi
 mkdir -p /ssh
 cp "$SSH_KEY" /ssh/id_rsa
 chmod 400 /ssh/id_rsa
fi

if [ "$MODE" != "REMOTE" ] && [ "$MODE" != "LOCAL" ]; then
  echo "Environment variable MODE is not correctly set. Possible values: 'REMOTE', 'LOCAL'."
  exit 1
fi

# Add logs for connection attempts
echo "Attempting to connect to $SSH_HOST at $(date)"

while true; do
  # Run the SSH command with ExitOnForwardFailure option
 if [ "$MODE" = "REMOTE" ];then
  ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -i /ssh/id_rsa -NL 0.0.0.0:"$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT" "$SSH_USER@$SSH_HOST" &
 elif [ "$MODE" = "LOCAL" ];then
  ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -i /ssh/id_rsa -NL "$LOCAL_HOST:$LOCAL_PORT:$REMOTE_PORT" "$SSH_USER@$SSH_HOST" &
 fi
 SSH_PID=$!

  # Wait for the SSH command to exit
  wait $SSH_PID
  # Add logs for connection status
  if [ $? -eq 0 ]; then
    echo "SSH connection to $SSH_HOST is active at $(date)"
  else
    echo "SSH connection to $SSH_HOST is not active at $(date)"
  fi

  # Wait for a while before attempting to reconnect
  sleep 5
done
