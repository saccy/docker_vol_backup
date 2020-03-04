#!/bin/bash

img='postgres'
vol_src='postgres_django0'
vol_tgt='/var/lib/postgresql/data/'
local_bkp='/Users/ahudson012/Code/docker_vol_backups'
cont_bkp_dir='/backup/postgres'
cont_bkp_file='backup.tar'

#Check volume exists
if ! docker volume inspect $vol_src > /dev/null 2>&1; then
    echo "cant find source volume: $vol_src"
    exit 1
fi

#Run the container, mount the data volume and bind a local backup dir
docker run \
    --rm \
    --mount source=${vol_src},target=${vol_tgt} \
    -v ${local_bkp}:${cont_bkp_dir} \
    $img tar -C $vol_tgt -cvf ${cont_bkp_dir}/${cont_bkp_file} ./
