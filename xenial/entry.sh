#!/bin/bash

echo '{"irods_host": "swcacti1.unm.edu", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "swcactiZone"}' | envsubst > $HOME/.irods/irods_environment.json

exec /usr/bin/tini -- ttyd tmux new -A -s ttyd bash
