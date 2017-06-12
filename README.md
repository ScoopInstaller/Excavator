# Scoop Bucket Updater

This container runs the updating services for all scoop manifest repositories:
- [main bucket](https://github.com/lukesampson/scoop)
- [extras bucket](https://github.com/lukesampson/scoop-extras)
- [versions bucket](https://github.com/scoopinstaller/versions)

## Usage

```
λ docker run -v /path/to/.ssh:/root/.ssh r15ch13/scoop-updater
```

## Environment Variables
Required for pushing changes with correct name/email to Github.
```
GIT_USERNAME=
GIT_EMAIL=
```

# License
[The MIT License (MIT)](https://r15ch13.mit-license.org/)
