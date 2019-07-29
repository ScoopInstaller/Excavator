# Excavator 🕳️
[![](https://images.microbadger.com/badges/image/r15ch13/excavator.svg)](https://microbadger.com/images/r15ch13/excavator) [![](https://images.microbadger.com/badges/version/r15ch13/excavator.svg)](https://microbadger.com/images/r15ch13/excavator)

This image allows for automated updates of [Scoop](https://scoop.sh) buckets.

## Usage
- Add `bin\bucket-updater.ps1` to your Bucket (see: [bucket-updater.ps1](#example-binbucket-updaterps1))
- Create `docker-compose.yml` on your Docker Host (see: [docker-compose.yml](#example-docker-composeyml))
- Run `docker-compose up`
- Add the generated public key to your GitHub account (see: ssh volume)

## Environment Variables
The following Environment Variables are required for pushing changes to GitHub.
```
BUCKET=<user>/<repo>        # GitHub Repo (e.g. lukesampson/scoop)
GIT_USERNAME=               # For "git config user.name"
GIT_EMAIL=                  # For "git config user.email"

# Optional:
SNOWFLAKES=curl,brotli      # Programs that should always be updated (comma separated)
CRONTAB=0 * * * *           # Change cron execution times (default: every hour)
METHOD=push                 # push = pushs to $BUCKET (default) / request = pull-request to $UPSTREAM
UPSTREAM=<user>/<repo>      # Upstream GitHub Repo for Pull-Request creating
SCOOP_DEBUG=true            # Enables Scoop debug output
```
## Example `bin\bucket-updater.ps1`
```powershell
param(
    # overwrite upstream param
    [String]$upstream = "<user>/<repo>:master"
)
if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }
$autopr = "$env:SCOOP_HOME/bin/auto-pr.ps1"
$dir = "$psscriptroot/.." # checks the parent dir
iex -command "$autopr -dir $dir -upstream $upstream $($args |% { "$_ " })"
```

## Example `docker-compose.yml`
```yaml
version: "3"

services:
  bucket:
    image: r15ch13/excavator:latest
    deploy:
      mode: global # creates only one container
    volumes:
      - ssh:/root/.ssh
      - logs:/root/log
    environment:
      GIT_USERNAME: "Max Muster"
      GIT_EMAIL: "max-muster@gmail.com"
      BUCKET: "maxmuster/my-bucket"
volumes:
  ssh:
  logs:
```

## These Scoop buckets get automated updates
- [Main Bucket](https://github.com/ScoopInstaller/Main)
- [Extras Bucket](https://github.com/lukesampson/scoop-extras)
- [Versions Bucket](https://github.com/ScoopInstaller/Versions)
- [PHP Bucket](https://github.com/ScoopInstaller/PHP)
- [Java Bucket](https://github.com/ScoopInstaller/Java)
- [Games Bucket](https://github.com/Calinou/scoop-games) by [@Calinou](https://github.com/Calinou)

## Logs
Current logs can be found at [https://scoop.r15.ch](https://scoop.r15.ch/?sort=time&order=desc)

# License
[The MIT License (MIT)](https://r15ch13.mit-license.org/)
