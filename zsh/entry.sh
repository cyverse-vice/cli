#!/bin/bash

echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_zone_name": "iplant"}' | tee  > /home/user/.irods/irods_environment.json

exec /usr/bin/tini -- ttyd tmux new -A -s ttyd zsh 
