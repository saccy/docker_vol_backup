## Bash and PowerShell scripts to backup and restore docker volumes to and from local storage

Uses the official alpine docker image to either:
- create a `.tar` file with the contents of an existing docker volume, OR
- restore the contents of a `.tar` file to a new docker volume

### Usage
linux:   `./linux/docker_volume_backup.sh -h`

I havent maintained the powerschell script. It will work but documentation is lacking.

windows: `.\windows\docker_volume_backup.ps1 -h`
