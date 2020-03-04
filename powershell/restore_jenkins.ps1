$img           = 'alpine'
$vol_src       = 'jenkins_django0'
$vol_tgt       = '/var/jenkins_home/'
$local_bkp     = 'D:\Code\github\saccy\docker_vol_backups\jenkins'
$cont_bkp_dir  = '/backup'
$cont_bkp_file = 'jenkins.tar'

docker volume inspect $vol_src 2>&1 | out-null
if($?)
{
    Write-Output "Found volume: $vol_src"
}
else
{
    Write-Output "Creating volume: $vol_src"
    docker volume create $vol_src | out-null
}

#Run the container, mount the data volume and bind a local backup dir
docker run `
    --rm `
    --mount source=${vol_src},target=${vol_tgt} `
    -v ${local_bkp}:${cont_bkp_dir} `
    $img tar xvf ${cont_bkp_dir}/${cont_bkp_file} -C ${vol_tgt}