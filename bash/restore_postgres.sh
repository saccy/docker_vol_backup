#!/bin/bash

img='postgres'
vol_src='postgres_django0'
vol_tgt='/var/lib/postgresql/data'
local_bkp='/Users/ahudson/Code/docker/docker_vol_backups/postgres'
cont_bkp_dir='/backup/postgres'
cont_bkp_file='backup.tar'

#Check volume exists
if ! docker volume inspect $vol_src > /dev/null 2>&1; then
    docker volume create $vol_src
fi

#Run the container, mount the data volume and bind a local backup dir
docker run \
    --rm \
    -it \
    --mount source=${vol_src},target=${vol_tgt} \
    -v ${local_bkp}:${cont_bkp_dir} \
    $img tar -C $vol_tgt -xvf ${cont_bkp_dir}/${cont_bkp_file} --strip=4
