param (
    [Parameter(Mandatory=$true)][string]$action,
    [Parameter(Mandatory=$true)][string]$vol_src,
    [Parameter(Mandatory=$true)][string]$vol_tgt,
    [Parameter(Mandatory=$true)][string]$local_bkp,
    [Parameter(Mandatory=$true)][string]$cont_bkp_dir,
    [Parameter(Mandatory=$true)][string]$cont_bkp_file
)

Class Backup {
    [String]$Img
    [String]$Vol_src
    [String]$Vol_tgt
    [String]$Local_bkp
    [String]$Cont_bkp_dir
    [String]$Cont_bkp_file

    Backup(
        [String]$img,
        [String]$vol_src,
        [String]$vol_tgt,
        [String]$local_bkp,
        [String]$cont_bkp_dir,
        [String]$cont_bkp_file
    ) {
        $this.Img           = $img
        $this.Vol_src       = $vol_src
        $this.Vol_tgt       = $vol_tgt
        $this.Local_bkp     = $local_bkp
        $this.Cont_bkp_dir  = $cont_bkp_dir
        $this.Cont_bkp_file = $cont_bkp_file
    }

    CreateBackup() {
        docker run `
            --rm `
            --mount "source=$($this.Vol_src),target=$($this.Vol_tgt)" `
            -v "$($this.Local_bkp):$($this.Cont_bkp_dir)" `
            $this.Img tar -C $this.Vol_tgt -cvf "$($this.Cont_bkp_dir)/$($this.Cont_bkp_file)" ./
    }

    RestoreBackup() {
        docker run `
            --rm `
            --mount "source=$($this.Vol_src),target=$($this.Vol_tgt)" `
            -v "$($this.Local_bkp):$($this.Cont_bkp_dir)" `
            $this.Img tar xvf "$($this.cont_bkp_dir)/$($this.cont_bkp_file)" -C $this.vol_tgt
    }
}

function preflight {
    param( [String]$action, [String]$vol_src )

    switch($action) {
        'backup' {
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
        }
        'restore' {
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
        }
        * {
            Write-Output "Unknown action: $action"
            exit 1
        }
    }
}

$img = 'alpine'

preflight($action, $vol_src)

[Backup]$backup = [Backup]::New($img, $vol_src, $vol_tgt, $local_bkp, $cont_bkp_dir, $cont_bkp_file)

switch($action) {
    'backup' {
        $backup.CreateBackup()
    }
    'restore' {
        $backup.RestoreBackup()
    }
}
