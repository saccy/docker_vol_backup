#TODO: write proper test case

#docker run -it --rm --mount source=test_vol,target=/tmp/code alpine sh -c "echo 'Hello, World!' > /tmp/code/test_file"
#docker run --rm --mount source=test_vol,target=/tmp/code alpine cat /tmp/code/test_file

./docker_volume_backup.ps1 `
    -action restore `
    -vol_src test_vol `
    -vol_tgt /tmp/code `
    -local_bkp D:\Code\github\saccy\docker_vol_backups\test `
    -cont_bkp_dir /backup/test `
    -cont_bkp_file backup.tar
