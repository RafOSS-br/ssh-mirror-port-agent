#!/bin/sh

echo $(id) | xargs | awk '{print $1}'
# Copy the ssh key to a non-root directory
mkdir -p /ssh
echo -e "$SSH_KEY" > /ssh/id_rsa
chmod 400 /ssh/id_rsa
if [ "$MODE" != "REMOTE" ] && [ "$MODE" != "LOCAL" ]; then
  echo "Environment variable MODE is not correctly set. Possible values: 'REMOTE', 'LOCAL'."
  exit 1
fi

# Add logs for connection attempts
echo "Attempting to connect to $SSH_HOST at $(date)"

while true; do
  # Run the SSH command with ExitOnForwardFailure option
 if [ "$MODE" = "REMOTE" ];then
  echo "Running: ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -i /ssh/id_rsa -NR $REMOTE_HOST:$REMOTE_PORT:$LOCAL_HOST:$LOCAL_PORT $SSH_USER@$SSH_HOST &"
  ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -i /ssh/id_rsa -NR $REMOTE_HOST:$REMOTE_PORT:$LOCAL_HOST:$LOCAL_PORT $SSH_USER@$SSH_HOST &
  # ssh -NR 0.0.0.0:1111:localhost:3306
  #   {LISTEN HOST}:{LISTEN PORT}:{BINDING HOST}:{BINDING PORT}
  # This example listening port 1111 remotely, use tunnel SSH to binding a local port
 elif [ "$MODE" = "LOCAL" ];then
  echo "Running: ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -i /ssh/id_rsa -NL $LOCAL_HOST:$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT $SSH_USER@$SSH_HOST &"
  ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -i /ssh/id_rsa -NL $LOCAL_HOST:$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT $SSH_USER@$SSH_HOST &
  # ssh -NL 0.0.0.0:1111:localhost:3306
  # {LISTEN HOST}:{LISTEN PORT}:{BINDING HOST}:{BINDING PORT}
  # This example listening port 1111 localy, use tunnel SSH to binding a remote port
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
