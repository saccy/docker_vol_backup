#!/bin/bash

#TODO: write proper test case

#docker run -it --rm --mount source=test_vol,target=/tmp/code alpine sh -c "echo 'Hello, World!' > /tmp/code/test_file"
#docker run --rm --mount source=test_vol,target=/tmp/code alpine cat /tmp/code/test_file

# ./docker_volume_backup.sh \
#     -a backup \
#     -s test_vol \
#     -t /tmp/code \
#     -l /Users/ahudson/Code/github/saccy/docker_vol_backup/test \
#     -d /backup/test \
#     -f backup.tar

./docker_volume_backup.sh \
    -a restore \
    -s test_vol \
    -t /tmp/code \
    -l /Users/ahudson/Code/github/saccy/docker_vol_backup/test \
    -d /backup/test \
    -f backup.tar
