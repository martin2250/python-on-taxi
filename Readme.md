# Python on TAXI
How to compile python to run on TAXI.

You can also use the precompiled binaries from the GitHub releases, just skip to `Installation`.

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
