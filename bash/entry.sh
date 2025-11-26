#!/bin/bash
# add irods config
echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > $HOME/.irods/irods_environment.json

# Add MCP servers for Claude Code using claude mcp add-json
# Add filesystem MCP server - provides file system access
claude mcp add-json filesystem '{
  "disabled": false,
  "timeout": 60,
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/jovyan/work", "/home/jovyan/data-store"],
  "autoApprove": ["read_file", "read_multiple_files", "write_file", "edit_file", "create_directory", "list_directory", "list_directory_with_sizes", "directory_tree", "move_file", "search_files", "get_file_info", "list_allowed_directories"]
}'

# Add fetch MCP server - provides web content fetching capabilities
claude mcp add-json fetch '{
  "disabled": false,
  "timeout": 60,
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-fetch"],
  "autoApprove": ["fetch"]
}'

# Add memory MCP server - provides persistent memory across sessions
claude mcp add-json memory '{
  "disabled": false,
  "timeout": 60,
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-memory"],
  "autoApprove": ["create_entities", "create_relations", "add_observations", "delete_entities", "delete_observations", "delete_relations", "read_graph", "search_nodes", "open_nodes"]
}'

# Add SQLite MCP server - provides database capabilities for data analysis
claude mcp add-json sqlite '{
  "disabled": false,
  "timeout": 60,
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sqlite", "/home/jovyan/work"],
  "autoApprove": ["read_query", "write_query", "create_table", "list_tables", "describe_table", "append_insight"]
}'

# Add datastore MCP server (HTTP transport) - provides CyVerse data store access
claude mcp add -t http datastore http://mcp.cyverse.ai/mcp

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

exec /usr/bin/tini -- ttyd -W tmux new -A -s ttyd bash
