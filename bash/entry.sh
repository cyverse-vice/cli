#!/bin/bash
# add irods config
echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > $HOME/.irods/irods_environment.json
# add mcp server
echo '{"mcpServers":{"filesystem":{"command":"npx","args":["-y","@modelcontextprotocol/server-filesystem","/home/jovyan/work","/home/jovyan/data","/home/jovyan/notebooks","/home/jovyan"],"env":{}}}}' > /home/jovyan/.claude.json

# Copy .gitconfig from volume mount (if it exists)
if [ -f /data-store/iplant/home/$IPLANT_USER/.gitconfig ]; then
  cp /data-store/iplant/home/$IPLANT_USER/.gitconfig ~/ 
fi

# Copy S3 AWS (if it exists)
if [ -d /data-store/iplant/home/$IPLANT_USER/.aws ]; then
  cp -r /data-store/iplant/home/$IPLANT_USER/.aws ~/ 
fi

# Copy SSH keys (if it exists)
if [ -d /data-store/iplant/home/$IPLANT_USER/.ssh ]; then
  cp -r /data-store/iplant/home/$IPLANT_USER/.ssh ~/ 
fi

exec /usr/bin/tini -- ttyd tmux new -A -s ttyd bash
