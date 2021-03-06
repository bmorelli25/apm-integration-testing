#!/usr/bin/env bash
# for details about how it works see https://github.com/elastic/apm-integration-testing#continuous-integration

set -ex

if [ $# -lt 2 ]; then
  echo "Argument missing, python agent version spec and stack version must be provided"
  exit 2
fi

version_type=${1%;*}
version=${1#*;}
stack_args=${2//;/ }

# use release version by default
python_pkg="elastic-apm==${version}"
if [[ ${version_type} == github ]]; then
  python_pkg="git+https://github.com/elastic/apm-agent-python.git@${version}"
else
  if [[ ${version} == latest ]]; then
    python_pkg="elastic-apm"
  fi
fi

export COMPOSE_ARGS="${stack_args} --no-apm-server-dashboards --no-apm-server-self-instrument --no-kibana --with-agent-python-django --with-agent-python-flask --python-agent-package='${python_pkg}' --force-build --build-parallel"
srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.
${srcdir}/python.sh
