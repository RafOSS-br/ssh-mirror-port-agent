#!/bin/sh
set -e

if [ ! -f "$SSH_KEY" ]; then
  echo "SSH key file not found at: $SSH_KEY"
  exit 1
fi
if [ $MODE -ne "REMOTE" ] && [ $MODE -ne "LOCAL" ]; then
  echo "Environment variable MODE is not corretly set. Possible values: 'REMOTE', 'LOCAL'."
  exit 1
fi

# Copy the ssh key to a non-root directory
mkdir -p /ssh
cp "$SSH_KEY" /ssh/id_rsa
chmod 400 /ssh/id_rsa

# Add logs for connection attempts
echo "Attempting to connect to $SSH_HOST at $(date)"

while true; do
  # Run the SSH command with ExitOnForwardFailure option
 if [ $MODE -eq "REMOTE" ];then
  ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -i /ssh/id_rsa -NL 0.0.0.0:"$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT" "$SSH_USER@$SSH_HOST" &
  SSH_PID=$!
 elif [ $MODE -eq "LOCAL" ];then
  ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -i /ssh/id_rsa -NL "$LOCAL_HOST:$LOCAL_PORT:$REMOTE_PORT" "$SSH_USER@$SSH_HOST" &
  SSH_PID=$!
 fi

  # Wait for the SSH command to exit
  wait $SSH_PID
  # Add logs for connection status
  if [ $? -eq 0 ]; then
    while true; do
    goto logging_ok
    sleep 60; done
  else
    goto logging_error
  fi

  # Wait for a while before attempting to reconnect
  sleep 5
done

logging_error:
    echo "SSH connection to $SSH_HOST is not active at $(date)"
logging_ok:
    echo "SSH connection to $SSH_HOST is active at $(date)"
