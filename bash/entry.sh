#!/bin/bash
# add irods config
echo '{"irods_host": "swcacti1.unm.edu", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "swcactiZone"}' | envsubst > $HOME/.irods/irods_environment.json

# Copy .gitconfig from volume mount (if it exists)
if [ -f /data-store/swcactiZone/home/$IPLANT_USER/.gitconfig ]; then
  cp /data-store/swcactiZone/home/$IPLANT_USER/.gitconfig ~/
fi

# Copy S3 AWS (if it exists)
if [ -d /data-store/swcactiZone/home/$IPLANT_USER/.aws ]; then
  cp -r /data-store/swcactiZone/home/$IPLANT_USER/.aws ~/
fi

# Copy SSH keys (if it exists)
if [ -d /data-store/swcactiZone/home/$IPLANT_USER/.ssh ]; then
  cp -r /data-store/swcactiZone/home/$IPLANT_USER/.ssh ~/
fi

# Mount S3 buckets from AWS config if credentials exist
if [ -f "$HOME/.aws/credentials" ] && [ -f "$HOME/.aws/config" ]; then
  echo "Found AWS credentials, mounting S3 buckets..."

  # Debug: Show available profiles
  echo "Available AWS profiles in config:"
  grep '^\[' "$HOME/.aws/config" | sed 's/\[//g; s/\]//g; s/profile //g'

  # Create associative arrays to store profile configurations
  declare -A profile_endpoints
  declare -A profile_regions
  declare -A profile_buckets

  current_profile=""

  # First pass: Parse the AWS config file to extract all profile information
  while IFS= read -r line; do
    # Check if this is a profile header
    if [[ "$line" =~ ^\[profile[[:space:]]+(.+)\]$ ]]; then
      current_profile="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^\[(.+)\]$ ]]; then
      current_profile="${BASH_REMATCH[1]}"
    fi

    # Skip if we don't have a current profile
    if [ -z "$current_profile" ]; then
      continue
    fi

    # Extract endpoint_url
    if [[ "$line" =~ ^[[:space:]]*endpoint_url[[:space:]]*=[[:space:]]*(.+)$ ]]; then
      profile_endpoints["$current_profile"]=$(echo "${BASH_REMATCH[1]}" | xargs)
    fi

    # Extract region
    if [[ "$line" =~ ^[[:space:]]*region[[:space:]]*=[[:space:]]*(.+)$ ]]; then
      profile_regions["$current_profile"]=$(echo "${BASH_REMATCH[1]}" | xargs)
    fi

    # Extract s3_bucket (or bucket)
    if [[ "$line" =~ ^[[:space:]]*(s3_bucket|bucket)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
      profile_buckets["$current_profile"]=$(echo "${BASH_REMATCH[2]}" | xargs)
    fi
  done < "$HOME/.aws/config"

  # Second pass: Mount buckets for each profile that has bucket information
  for profile in "${!profile_buckets[@]}"; do
    bucket="${profile_buckets[$profile]}"

    # Skip if no bucket defined
    if [ -z "$bucket" ]; then
      continue
    fi

    echo "Processing profile '$profile' with bucket '$bucket'"

    # Get endpoint and region with defaults
    endpoint_url="${profile_endpoints[$profile]:-}"
    region="${profile_regions[$profile]:-us-east-1}"

    # Create mount point
    mount_point="/osn/${bucket}"
    sudo mkdir -p "$mount_point"
    sudo chown jovyan:jovyan "$mount_point"

    # Prepare s3fs options
    s3fs_opts="passwd_file=$HOME/.aws/credentials,profile=$profile,use_path_request_style"

    if [ -n "$endpoint_url" ]; then
      s3fs_opts="${s3fs_opts},url=${endpoint_url}"
      echo "  Using endpoint: $endpoint_url"
    fi

    # Add additional recommended options
    s3fs_opts="${s3fs_opts},allow_other,uid=$(id -u),gid=$(id -g),umask=0022,mp_umask=0022"

    # Mount the bucket
    echo "  Mounting bucket '$bucket' at '$mount_point'"

    if sudo s3fs "$bucket" "$mount_point" -o "$s3fs_opts"; then
      echo "  ✓ Successfully mounted $bucket"
    else
      echo "  ✗ Failed to mount $bucket (check credentials and bucket access)"
    fi
  done

  # If no buckets were explicitly defined, try to infer from profile names
  if [ ${#profile_buckets[@]} -eq 0 ]; then
    echo "No explicit bucket configurations found, attempting to infer from profile names..."

    # Parse credentials file for profiles
    while IFS= read -r line; do
      if [[ "$line" =~ ^\[(.+)\]$ ]]; then
        profile="${BASH_REMATCH[1]}"

        # Check if this profile has an endpoint in the config
        if [ -n "${profile_endpoints[$profile]}" ]; then
          # Use profile name as bucket name (common convention)
          bucket="$profile"
          endpoint_url="${profile_endpoints[$profile]}"
          region="${profile_regions[$profile]:-us-east-1}"

          mount_point="/osn/${bucket}"
          sudo mkdir -p "$mount_point"
          sudo chown jovyan:jovyan "$mount_point"

          s3fs_opts="passwd_file=$HOME/.aws/credentials,profile=$profile,use_path_request_style,url=${endpoint_url}"
          s3fs_opts="${s3fs_opts},allow_other,uid=$(id -u),gid=$(id -g),umask=0022,mp_umask=0022"

          echo "  Attempting to mount inferred bucket '$bucket' for profile '$profile'"

          if sudo s3fs "$bucket" "$mount_point" -o "$s3fs_opts" 2>/dev/null; then
            echo "  ✓ Successfully mounted inferred bucket $bucket"
          else
            echo "  ℹ Could not mount bucket '$bucket' (may not exist or profile name doesn't match bucket name)"
          fi
        fi
      fi
    done < "$HOME/.aws/credentials"
  fi

  # Show final status
  echo ""
  echo "S3 bucket mounting complete. Mounted buckets:"
  mount | grep "/osn/" | awk '{print "  - " $1 " -> " $3}' || echo "  No buckets currently mounted"
fi

# Optional user init hook. The "User init script" app parameter reaches us as
# `--init-script <basename>`, so that parameter's "Argument option" field must
# be set to --init-script in the DE; leave it empty and only the bare value is
# passed, which this deliberately ignores. VICE_INIT_SCRIPT does the same when
# testing outside the DE. Nothing runs unless one of them names a script.
# A hook is capped at a flat two minutes, deliberately not configurable: the
# cap exists to protect the DE's readiness check, and a knob to raise it would
# just be a knob to defeat it.
INIT_LOG="$HOME/.vice-init.log"
INIT_SCRIPT="${VICE_INIT_SCRIPT:-}"
hook=""

# Log argv: whether an app parameter actually reaches the container is worth
# being able to confirm from a real launch.
echo "entry.sh args: $*" >> "$INIT_LOG"

# Prefer --init-script, but accept a bare value: the DE only emits the flag
# when the app parameter's "Argument option" field is filled in, and passes the
# value alone otherwise. A bare value is unambiguous because this image
# declares no CMD, so argv is empty unless the DE supplied a parameter.
#
# Shift one at a time. `shift 2` is a trap here: a parameter left blank in the
# DE arrives as a bare trailing --init-script, and shifting past the end is a
# no-op that spins forever.
while [ $# -gt 0 ]; do
  case "$1" in
    --init-script) INIT_SCRIPT="${2:-}" ;;
    *) [ -n "$INIT_SCRIPT" ] || INIT_SCRIPT="$1" ;;
  esac
  shift
done

if [ -n "$INIT_SCRIPT" ]; then
  # The DE passes the file's basename, and the iRODS CSI driver mounts any
  # selected input at /data-store/input/<basename>, wherever in the data store
  # the user picked it from. The bare path covers local testing.
  for candidate in \
    "/data-store/input/$(basename "$INIT_SCRIPT")" \
    "$INIT_SCRIPT"
  do
    [ -f "$candidate" ] && [ -r "$candidate" ] && hook="$candidate" && break
    echo "init hook: tried $candidate" >> "$INIT_LOG"
  done

  # Confine the hook to the data store. Checking mode bits would prove nothing:
  # irodsfs synthesizes them from the CSI uid/gid attributes, not iRODS ACLs.
  case "$(readlink -f "$hook" 2>/dev/null)" in
    /data-store/*|"$HOME"/*) ;;
    *) echo "init hook: no usable script for '$INIT_SCRIPT'" >> "$INIT_LOG"; hook="" ;;
  esac
fi

if [ -n "$hook" ]; then
  echo "Running user init hook: $hook (log $INIT_LOG)"
  # `bash "$hook"` rather than `"$hook"`: the executable bit does not survive
  # the data store. A child process rather than `source`: a sourced hook could
  # clobber this script.
  timeout --kill-after=10 120 bash "$hook" >> "$INIT_LOG" 2>&1 ||
    echo "user init hook failed or timed out, continuing with defaults (see $INIT_LOG)"
fi

# Start the shell in ~ regardless of the tool's working directory. That setting
# has to stay at ~/data-store: the DE mounts the analysis's persistent volume
# at the container's working directory, so pointing it at /home/jovyan would
# mount a volume over the home directory and hide .bashrc, .bash_profile and
# everything else the image ships. tmux takes the cwd of every window from the
# session it starts in, so changing directory here is enough.
cd "$HOME" || true

exec /usr/bin/tini -- ttyd -W tmux new -A -s ttyd bash
