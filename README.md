# SSH MIRROR PORT AGENT CONTAINERIZED

## MODES
The flag MODE is environment variable. This flag indicates the port to be mirrored.

### If mode is "REMOTE":

In this case, a remote port is mirrored in local port.

Required environment varible:
- MODE: is "REMOTE"
- LOCAL_PORT: The port listed by SSH
- REMOTE_HOST: The remote host
- REMOTE_PORT: The remote port (this port will be mirrored in local port)

### If mode is "LOCAL":

In this case, a local port is mirrored in remote port of SSH HOST.

Required environment variable:
- MODE: is "LOCAL"
- LOCAL_HOST: The local host
- LOCAL_PORT: The local port (this port will be mirrored in remote port)
- REMOTE_PORT: The remote port listed by SSH


### Authentication environment variable
- SSH_USER: The user of SSH server
- SSH_HOST: The host of SSH server
- SSH_KEY: The path of SSH KEY to SSH server (no password)
