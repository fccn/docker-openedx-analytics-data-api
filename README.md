# Open edX analytics api docker builder

Builds a docker container with the Open edX edx-analytics-data-api.

By default builds the upstream repository https://github.com/openedx/edx-analytics-data-api.git
for the `master` branch, but it's possible to build other fork.

Tested for the **lilac** open edx release.

## Clean
Execute it like:
```bash
make clean
```

## Clone
Git clone the analyticsapi code to analyticsapi folder.
```bash
make repository=https://github.com/fccn/edx-analytics-data-api.git branch=nau/lilac.master clone
```

## Build

Execute it like:
```bash
make build
```
