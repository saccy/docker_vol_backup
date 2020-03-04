$img           = 'alpine'
$vol_src       = 'postgres_django0'
$vol_tgt       = '/var/lib/postgresql/data/'
$local_bkp     = 'D:\Code\github\saccy\docker_vol_backups\postgres'
$cont_bkp_dir  = '/backup'
$cont_bkp_file = 'postgres.tar'

docker volume inspect $vol_src 2>&1 | out-null
if($?)
{
    Write-Output "Found volume: $vol_src"
}
else
{
    Write-Output "ERROR could not find volume: $vol_src"
    exit 1
}

#Run the container, mount the data volume and bind a local backup dir
docker run `
    --rm `
    --mount source=${vol_src},target=${vol_tgt} `
    -v ${local_bkp}:${cont_bkp_dir} `
    $img tar -C $vol_tgt -cvf ${cont_bkp_dir}/${cont_bkp_file} ./
