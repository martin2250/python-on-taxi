# Python on TAXI
How to compile python to run on TAXI.

You can also use the precompiled binaries from the GitHub releases, just skip to `Installation`.


## Toolchain Setup
We're using a docker image to compile everything, this makes it much easier to set up the toolchain.

Start the docker container:
```bash
docker run --name python-on-taxi-musleabi -it rustembedded/cross:armv5te-unknown-linux-musleabi /bin/bash
# or to resume
docker exec -it python-on-taxi-musleabi bash
```

## Building Python
```bash
docker build -t taxi-python .
rm -rf output
mkdir -p output
docker run -v $PWD/output:/output taxi-python /steps/package.sh
```

## Installation
Install python on the TAXI:
```bash
cat output/python3.9.5-musleabi.tar.gz | ssh taxi114 'tar -C / -xvzf -'
cat output/python3.9-modules-musleabi.tar.gz | ssh taxi114 'tar -C / -xvzf -'
```

Before installing a new version of python, remove the old one:
```bash
cd /
./uninstall_python.sh
```
