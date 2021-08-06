#!/bin/bash

echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | tee  > /home/user/.irods/irods_environment.json

/usr/bin/tini -- ttyd bash