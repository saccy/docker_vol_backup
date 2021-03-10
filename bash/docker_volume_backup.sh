#!/bin/bash
set -e

backup() {
    local vol_src=$1
    local vol_tgt=$2
    local local_bkp=$3
    local cont_bkp_dir=$4
    local cont_bkp_file=$5
    local img=$6

    echo "Backing up volume: $vol_src"

    docker run \
        --rm \
        --mount source=${vol_src},target=${vol_tgt} \
        -v ${local_bkp}:${cont_bkp_dir} \
        $img tar -C $vol_tgt -cvf ${cont_bkp_dir}/${cont_bkp_file} ./

    echo "Successfully backed up volume $vol_src to ${local_bkp}/${cont_bkp_file}"
}

# FIXME: need to find the latest backup automatically. Using an auto timestamp dont work for restores.
restore() {
    local vol_src=$1
    local vol_tgt=$2
    local local_bkp=$3
    local cont_bkp_dir=$4
    local cont_bkp_file=$5
    local img=$6
    
    echo "Restoring volume: $vol_src"

    docker run \
        --rm \
        -it \
        --mount source=${vol_src},target=${vol_tgt} \
        -v ${local_bkp}:${cont_bkp_dir} \
        $img tar -C $vol_tgt -xvf ${cont_bkp_dir}/${cont_bkp_file}

    echo "Successfully restored volume $vol_src from ${local_bkp}/${cont_bkp_file}"
}

preflight() {
    local action=$1
    local vol_src=$2
    local backup_file=$3

    case $action in
        'backup')
            if ! docker volume inspect $vol_src > /dev/null 2>&1; then
                echo "[ERROR] cant find source volume: $vol_src"
                exit 1
            fi
            ;;
        'restore')
            if ! docker volume inspect $vol_src > /dev/null 2>&1; then
                echo "Creating source volume:"
                docker volume create $vol_src
            else
                echo "[ERROR] Docker volume $vol_src already exists"
                exit 1
            fi
            ;;
        *)
            echo "[ERROR] Unknown action: $action"
            exit 1
            ;;
    esac

    ext=$(echo "$backup_file" | awk -F . '{print $NF}')
    if [[ $ext != 'tar' ]]; then
        echo "[ERROR] Make sure you specify a .tar file for backup and restores. File specified: $backup_file"
        exit 1
    fi

}

# TODO: 
#   option: force a restore to existing volume
#   option: specify file to backup to/restore from
# FIXME: forcing .tar backups is shit
usage() {
    echo "Usage: ${0} -a action -v docker_volume -b backup_directory"
    echo ""
    echo "  Use this script to create tar backups of your docker volumes"
    echo ""
    echo "Options:"
    echo "  -a backup|restore   Action: Create a backup or restore from an existing backup       (required)"
    echo "  -v TEXT             Docker volume: Name of docker volume to backup or restore from   (required)"
    echo "  -b TEXT             Backup file: Absolute path to backup tar file                    (required)"
    echo "  -h                  Help: Displays this message"
    echo ""
    echo "example: ${0} -a backup -v my_volume -b /home/docker_volume_backups/backup.tar"
    exit 1
}

# Main
while getopts "a:v:b:h" opt; do
    case $opt in
        'a')
            if [[ $OPTARG =~ ^(backup|restore)$ ]]; then
                action=${OPTARG}
            else
                echo "Invalid option: $OPTARG"
                usage
            fi
            ;;
        'v')
            vol_src=${OPTARG}
            ;;
        'b')
            local_bkp=${OPTARG}
            ;;
        'h')
            usage
            ;;
        *)
            echo "Invalid flag: \"-${OPTARG}\"" >&2
            usage
            ;;
    esac
done

if [[ ! -n $action || ! -n $vol_src || ! -n $local_bkp ]]; then
    echo "Missing a required parameter"
    usage
fi

# Global vars
vol_tgt='/docker_vol'
cont_bkp_dir='/backups'
img='alpine'
cont_bkp_file=$(basename ${local_bkp})
local_bkp_dir=$(dirname ${local_bkp})

# Validate pre-flight checks before proceeding
preflight $action $vol_src $cont_bkp_file

$action $vol_src $vol_tgt $local_bkp_dir $cont_bkp_dir $cont_bkp_file $img
