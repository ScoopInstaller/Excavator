# Excavator 🕳️
[![](https://images.microbadger.com/badges/image/r15ch13/excavator.svg)](https://microbadger.com/images/r15ch13/excavator) [![](https://images.microbadger.com/badges/version/r15ch13/excavator.svg)](https://microbadger.com/images/r15ch13/excavator)

This container runs the updating services for all [Scoop](http://scoop.sh) buckets:
- [Main Bucket](https://github.com/lukesampson/scoop)
- [Extras Bucket](https://github.com/lukesampson/scoop-extras)
- [Versions Bucket](https://github.com/scoopinstaller/versions)

## Usage

```
λ docker run -v /path/to/.ssh:/root/.ssh r15ch13/excavator
```

## Environment Variables
Required for pushing changes with correct name/email to Github.
```
GIT_USERNAME=
GIT_EMAIL=
```

# License
[The MIT License (MIT)](https://r15ch13.mit-license.org/)
