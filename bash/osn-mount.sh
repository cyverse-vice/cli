#!/bin/bash

# Helper script for managing OSN bucket mounts
# This script can be called manually by users to mount/unmount buckets

function show_usage() {
    cat << EOF
Usage: osn-mount.sh [COMMAND] [OPTIONS]

Commands:
    mount-all       Mount all buckets from AWS config
    mount           Mount a specific bucket
    unmount         Unmount a specific bucket
    unmount-all     Unmount all OSN buckets
    list            List currently mounted buckets
    template        Show AWS config template

Options:
    -b, --bucket    Bucket name (for mount/unmount commands)
    -p, --profile   AWS profile to use (default: default)
    -e, --endpoint  S3 endpoint URL
    -h, --help      Show this help message

Example AWS config format (~/.aws/config):
    [profile myosn]
    region = us-east-1
    endpoint_url = https://mghp.osn.xsede.org
    s3_bucket = my-bucket-name

Example AWS credentials (~/.aws/credentials):
    [myosn]
    aws_access_key_id = YOUR_ACCESS_KEY
    aws_secret_access_key = YOUR_SECRET_KEY

EOF
}

function mount_bucket() {
    local bucket="$1"
    local profile="${2:-default}"
    local endpoint="$3"

    local mount_point="/osn/${bucket}"

    # Create mount point
    sudo mkdir -p "$mount_point"
    sudo chown jovyan:jovyan "$mount_point"

    # Build s3fs options
    local s3fs_opts="passwd_file=$HOME/.aws/credentials,profile=$profile,use_path_request_style"
    s3fs_opts="${s3fs_opts},allow_other,uid=$(id -u),gid=$(id -g),umask=0022,mp_umask=0022"

    if [ -n "$endpoint" ]; then
        s3fs_opts="${s3fs_opts},url=${endpoint}"
    fi

    echo "Mounting bucket $bucket at $mount_point with profile $profile"
    sudo s3fs "$bucket" "$mount_point" -o "$s3fs_opts"

    if [ $? -eq 0 ]; then
        echo "Successfully mounted $bucket"
    else
        echo "Failed to mount $bucket"
        return 1
    fi
}

function unmount_bucket() {
    local bucket="$1"
    local mount_point="/osn/${bucket}"

    if mountpoint -q "$mount_point"; then
        echo "Unmounting $bucket from $mount_point"
        sudo umount "$mount_point"

        if [ $? -eq 0 ]; then
            echo "Successfully unmounted $bucket"
            sudo rmdir "$mount_point" 2>/dev/null
        else
            echo "Failed to unmount $bucket"
            return 1
        fi
    else
        echo "$mount_point is not mounted"
        return 1
    fi
}

function list_mounted() {
    echo "Currently mounted OSN buckets:"
    mount | grep "/osn/" | awk '{print $1 " -> " $3}'

    if [ $(mount | grep -c "/osn/") -eq 0 ]; then
        echo "No OSN buckets currently mounted"
    fi
}

function unmount_all() {
    echo "Unmounting all OSN buckets..."
    for mount_point in $(mount | grep "/osn/" | awk '{print $3}'); do
        bucket=$(basename "$mount_point")
        unmount_bucket "$bucket"
    done
}

function mount_all_from_config() {
    if [ ! -f "$HOME/.aws/config" ] || [ ! -f "$HOME/.aws/credentials" ]; then
        echo "Error: AWS config or credentials file not found"
        return 1
    fi

    echo "Mounting all buckets from AWS config..."

    # Parse config file for s3_bucket entries
    local current_profile=""
    local bucket=""
    local endpoint=""

    while IFS= read -r line; do
        # Check for profile header
        if [[ "$line" =~ ^\[profile[[:space:]]+(.+)\]$ ]] || [[ "$line" =~ ^\[(.+)\]$ ]]; then
            current_profile="${BASH_REMATCH[1]}"
            if [[ "$current_profile" == "profile default" ]]; then
                current_profile="default"
            fi
            endpoint=""
            bucket=""
        fi

        # Check for endpoint_url
        if [[ "$line" =~ ^endpoint_url[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            endpoint="${BASH_REMATCH[1]}"
            endpoint=$(echo "$endpoint" | xargs)
        fi

        # Check for s3_bucket
        if [[ "$line" =~ ^s3_bucket[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            bucket="${BASH_REMATCH[1]}"
            bucket=$(echo "$bucket" | xargs)

            if [ -n "$bucket" ] && [ -n "$current_profile" ]; then
                mount_bucket "$bucket" "$current_profile" "$endpoint"
            fi
        fi
    done < "$HOME/.aws/config"

    list_mounted
}

function show_template() {
    cat << EOF
AWS Config Template for OSN Buckets
====================================

Add the following to ~/.aws/config:

[profile osn-bucket1]
region = us-east-1
endpoint_url = https://uaz1.osn.mghpcc.org
s3_bucket = my-bucket-name

[profile osn-bucket2]
region = us-west-2
endpoint_url = https://sdsc.osn.xsede.org
s3_bucket = another-bucket

Add the following to ~/.aws/credentials:

[osn-bucket1]
aws_access_key_id = YOUR_ACCESS_KEY_1
aws_secret_access_key = YOUR_SECRET_KEY_1

[osn-bucket2]
aws_access_key_id = YOUR_ACCESS_KEY_2
aws_secret_access_key = YOUR_SECRET_KEY_2

Common OSN Endpoints:
- UArizona: https://uaz1.osn.mghpcc.org
- MGHP: https://mghp.osn.xsede.org
- NCSA: https://ncsa.osn.xsede.org
- SDSC: https://sdsc.osn.xsede.org
- PSC: https://psc.osn.xsede.org
- JHU: https://jhu.osn.xsede.org

After configuring, run: osn-mount.sh mount-all
EOF
}

# Main script logic
case "$1" in
    mount-all)
        mount_all_from_config
        ;;
    mount)
        shift
        BUCKET=""
        PROFILE="default"
        ENDPOINT=""

        while [[ $# -gt 0 ]]; do
            case $1 in
                -b|--bucket)
                    BUCKET="$2"
                    shift 2
                    ;;
                -p|--profile)
                    PROFILE="$2"
                    shift 2
                    ;;
                -e|--endpoint)
                    ENDPOINT="$2"
                    shift 2
                    ;;
                *)
                    echo "Unknown option: $1"
                    show_usage
                    exit 1
                    ;;
            esac
        done

        if [ -z "$BUCKET" ]; then
            echo "Error: Bucket name required"
            show_usage
            exit 1
        fi

        mount_bucket "$BUCKET" "$PROFILE" "$ENDPOINT"
        ;;
    unmount)
        shift
        BUCKET=""

        while [[ $# -gt 0 ]]; do
            case $1 in
                -b|--bucket)
                    BUCKET="$2"
                    shift 2
                    ;;
                *)
                    echo "Unknown option: $1"
                    show_usage
                    exit 1
                    ;;
            esac
        done

        if [ -z "$BUCKET" ]; then
            echo "Error: Bucket name required"
            show_usage
            exit 1
        fi

        unmount_bucket "$BUCKET"
        ;;
    unmount-all)
        unmount_all
        ;;
    list)
        list_mounted
        ;;
    template)
        show_template
        ;;
    -h|--help|help)
        show_usage
        ;;
    *)
        echo "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac