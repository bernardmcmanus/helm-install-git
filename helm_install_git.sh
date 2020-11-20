#!/bin/bash

set -euo pipefail

function usage {
cat << EOF
Helm Plugin Install Git
This plugin provides the ability to install helm charts directly from a git repository.

Usage:
  helm install-git <owner>/<repo>/<version> [flags]

Example:
  # See https://github.com/pusher/wave/tree/56a05d7

  helm install-git \
    pusher/wave/56a05d7 \
    --atomic \
    --timeout 2m \
    --values <(
      echo "replicas: 3"
      echo "syncPeriod: 5m"
    )
EOF
}

function log {
  >&2 echo "[helm-install-git] $@"
}

if ! [[ $# ]] || [[ "${@:1}" =~ -h$|--help$|^help$ ]]; then
  usage
  exit
fi

identifier=$1
owner=`echo $identifier | awk -F/ '{ print $1; }'`
repo=`echo $identifier | awk -F/ '{ print $2; }'`
version=`echo $identifier | awk -F/ '{ print $3; }'`
version=${version:-"master"}
release_name=$repo

while (( $# )); do
  case "$1" in
    $identifier)
      shift 1;
      ;;
    --name|--name-template)
      release_name="${2-}"
      shift 2
      ;;
    *)
      helm_args+=("$1")
      shift 1
      ;;
  esac
done

tmp_dir=`mktemp -d`

trap 'rm -rf $tmp_dir' EXIT

cd $tmp_dir

url=https://github.com/$owner/$repo/tarball/$version

package_file=

log "Downloading: $url"

curl -L# $url | tar -xzf -

# Helm requires that the directory name and Chart.yaml name match
old_chart_dir=`dirname $(find . -name Chart.yaml)`
chart_dir=$(dirname $old_chart_dir)/$repo
mv $old_chart_dir $chart_dir

helm package $chart_dir
package_file=$PWD/$(ls $repo-*.tgz)

exec helm upgrade $release_name $package_file --install ${helm_args[*]}
