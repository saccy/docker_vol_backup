#!/bin/bash

backup_test() {
    local test_vol=$1

    # Create a test volume add some dummy data to it
    docker run \
        -it \
        --rm \
        --mount source=${test_vol},target=/tmp/code \
        alpine sh -c "echo 'Hello, World!' > /tmp/code/test_file"

    # Backup the test volume
    ./docker_volume_backup.sh \
        -a backup \
        -v ${test_vol} \
        -b /Users/andrew/Code/pg_dumper/${test_vol}.tar

    tar -xvzf "/Users/andrew/Code/pg_dumper/${test_vol}.tar"
    test_out="$(cat ./test_file)"

    docker volume rm $test_vol > /dev/null

    if [[ $test_out == 'Hello, World!' ]]; then
        echo "[SUCCESS] Backup test successful"
        exit 0
    else
        echo "[ERROR] Backup test failed"
        exit 1
    fi

}

restore_test() {
    local test_vol=$1

    # Create a new docker volume from an existing backup file
    ./docker_volume_backup.sh \
        -a restore \
        -v ${test_vol} \
        -b /Users/andrew/Code/pg_dumper/${test_vol}.tar

    test_out="$(docker run --rm --mount source=${test_vol},target=/tmp/code alpine cat /tmp/code/test_file)"

    docker volume rm $test_vol > /dev/null

    if [[ $test_out == 'Hello, World!' ]]; then
        echo "[SUCCESS] Restore test successful"
        exit 0
    else
        echo "[ERROR] Restore test failed"
        exit 1
    fi

}

# Main
action=$1 # backup|restore
test_vol='test_volume'

# backup_test $test_vol
${action}_test $test_vol
