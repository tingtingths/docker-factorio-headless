#!/usr/bin/env sh

REPO='/volume1/homes/ting/git_repos/docker-factorio-headless'

cd $REPO || exit 1

latest_version=$(/usr/bin/env python3 $REPO/check_version/get_factorio_version.py)

#git clean -f && git checkout -- .
# check git version
version=$(sed -n -E 's|ENV VERSION (.+)|\1|p' Dockerfile)

if [ ! "$version" ]; then
    echo 'Cannot get version string...'
    exit 1
fi

echo 'Current: '"$version"', latest: '"$latest_version"

if [ "$version" != "$latest_version" ]; then
    sed -E -i 's|(ENV VERSION ).+|\1'"$latest_version"'|g' Dockerfile
    git add Dockerfile
    git commit -m 'Version '"$latest_version"
    git tag "$latest_version"
    git push --follow-tags
fi