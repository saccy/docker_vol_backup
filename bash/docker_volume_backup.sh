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

restore() {
    local vol_src=$1
    local vol_tgt=$2
    local local_bkp=$3
    local cont_bkp_dir=$4
    local cont_bkp_file=$5
    local img=$6
    local strip=$7
    
    echo "Restoring volume: $vol_src"

    docker run \
        --rm \
        -it \
        --mount source=${vol_src},target=${vol_tgt} \
        -v ${local_bkp}:${cont_bkp_dir} \
        $img tar -C $vol_tgt -xvf ${cont_bkp_dir}/${cont_bkp_file}
        #$img tar -C $vol_tgt -xvf ${cont_bkp_dir}/${cont_bkp_file} --strip=${strip}

    echo "Successfully restored volume $vol_src from ${local_bkp}/${cont_bkp_file}"
}

#FIXME: more control over whether to force a restore to existing volume
preflight() {
    local action=$1
    local vol_src=$2

    case $action in
        'backup')
            if ! docker volume inspect $vol_src > /dev/null 2>&1; then
                echo "cant find source volume: $vol_src"
                exit 1
            fi
            ;;
        'restore')
            if ! docker volume inspect $vol_src > /dev/null 2>&1; then
                echo "Creating source volume:"
                docker volume create $vol_src
            else
                echo "Docker volume $vol_src already exists"
                exit 1
            fi
            ;;
        *)
            echo "Unknown action: $action"
            exit 1
    esac
}

#TODO: fix usage and example lines
usage() {
    echo "usage: ${0} -a [backup||restore]"
    echo "  -a <action> Backup or restore a docker volume"
    echo "  -s <volume source> The volume to backup or restore"
    echo "  -t <volume target> The directory in the container to mount volume source on"
    echo "  -l <local backup dir> Host directory to bind mount"
    echo "  -d <container backup dir> Container directory to bind to local host"
    echo "  -f <container backup file> File to backup to or restore from in container"
    echo "  -h <help> Display this message"
    echo "example: ${0} -a backup"
    exit 1
}

#Main
while getopts "a:s:t:l:d:f:h" opt; do
    case $opt in
        'a')
            if [[ $OPTARG =~ ^(backup|restore)$ ]]; then
                action=${OPTARG}
            else
                echo "Invalid option: $OPTARG"
                usage
            fi
            ;;
        's')
            vol_src=${OPTARG}
            ;;
        't')
            vol_tgt=${OPTARG}
            ;;
        'l')
            local_bkp=${OPTARG}
            ;;
        'd')
            cont_bkp_dir=${OPTARG}
            ;;
        'f')
            cont_bkp_file=${OPTARG}
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

if [[ ! -n $action || ! -n $vol_src || ! -n $vol_tgt || ! -n $local_bkp || ! -n $cont_bkp_dir || ! -n $cont_bkp_file ]]; then
    echo "Missing a required parameter"
    usage
fi

img='alpine'

preflight $action $vol_src

#FIXME: strip argument for restore
$action $vol_src $vol_tgt $local_bkp $cont_bkp_dir $cont_bkp_file $img
