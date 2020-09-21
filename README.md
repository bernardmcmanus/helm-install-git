# Helm Plugin Install Git

> A Helm plugin to install charts directly from a git repository.

## Installation

```shell
helm plugin install --version master https://github.com/bernardmcmanus/helm-plugin-install-git.git
```

## Upgrading

```shell
helm plugin update install-git
```

## Usage

```shell
# See https://github.com/pusher/wave/tree/56a05d7

helm install-git \
  pusher/wave/56a05d7 \
  --atomic \
  --timeout 2m \
  --values <(
    echo "replicas: 3"
    echo "syncPeriod: 5m"
  )
```
