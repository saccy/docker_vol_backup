## Bash and PowerShell scripts to backup and restore docker volumes to and from local storage

Uses the official alpine docker image to either:
- create a .tar file of the contents of an existing docker volume, OR
- restore the contents of a .tar file to a new docker volume

This has come in handy when developing in a container with persistent storage and having to switch between mac and windows, i.e. finish dev on mac and backup volume > restore volume on windows and restart work 

### TODO:
* better argument names (powershell and bash arg names differ)
* better examples (include usage example in README)
* error handling
* additional storage options
    * s3
    * az blob
* additional storage formats
    * zip
    * tar.gz
* better output (comments, updates, results etc.)
    