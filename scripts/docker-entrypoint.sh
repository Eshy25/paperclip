#!/bin/sh
set -e

# Capture runtime UID/GID from environment variables, defaulting to 1000
PUID=${USER_UID:-1000}
PGID=${USER_GID:-1000}

# If already running as non-root (e.g. Railway, or USER directive in Dockerfile),
# skip all privilege escalation and just exec the command directly.
if [ "$(id -u)" -ne 0 ]; then
    exec "$@"
    fi

    # Adjust the node user's UID/GID if they differ from the runtime request
    # and fix volume ownership only when a remap is needed
    changed=0

    if [ "$(id -u node)" -ne "$PUID" ]; then
        echo "Updating node UID to $PUID"
            usermod -o -u "$PUID" node
                changed=1
                fi

                if [ "$(id -g node)" -ne "$PGID" ]; then
                    echo "Updating node GID to $PGID"
                        groupmod -o -g "$PGID" node
                            usermod -g "$PGID" node
                                changed=1
                                fi

    # Always fix volume ownership (Railway volumes mount as root)
        chown -R node:node /paperclip

        exec gosu node "$@"
                                    
