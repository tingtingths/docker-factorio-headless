#!/usr/bin/env sh

latest_version=$(./get_factorio_version.py)

if [ ! "${latest_version}" ]; then
	echo 'Cannot get latest version...'
	exit 1
fi

version=$(sed -n -E 's|ARG FACTORIO_VERSION=(.+)|\1|p' Dockerfile)

if [ ! "${version}" ]; then
    echo 'Cannot get version string...'
    exit 1
fi

echo 'Current: '"${version}"', latest: '"${latest_version}"

if [ "${version}" != "${latest_version}" ]; then
    sed -i "" -E -e "s|ARG FACTORIO_VERSION=.+|ARG FACTORIO_VERSION=${latest_version}|" Dockerfile
    git add Dockerfile
    git commit -m "Version ${latest_version}"
    git tag "${latest_version}"
    git push && git push --tags
fi
