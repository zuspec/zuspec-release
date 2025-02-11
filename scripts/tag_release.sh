#!/bin/bash -x

version="0.0.8"

scripts_dir=$(dirname $(realpath $0))
proj_dir=$(dirname ${scripts_dir})

echo "Ensuring source is up-to-date"
${proj_dir}/packages/python/bin/ivpm sync
if test $? -ne 0; then exit 1; fi

packages="zuspec-parser zuspec-arl-dm zuspec-fe-parser zuspec-arl-eval" 
packages="$packages zuspec-be-sw zuspec-sv"

for pkg in $packages; do
    echo "pkg: ${pkg}"
    cd ${proj_dir}/packages/${pkg} || exit 1
    files=$(find python -name __version__.py)
    if test $(echo $files | wc -l) -ne 1; then
        echo "Error: more than one __version__.py file found"
        exit 1
    fi
    ex_version=$(sed -e "s/BASE=\"\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)\"/\1/g" $files)
    if test ${ex_version} != ${version}; then
        echo "Error: version mismatch: ${ex_version} != ${version}"
        exit 1
    fi
done

# Now, go through and create tags
for pkg in $packages; do
    echo "pkg: ${pkg}"
    cd ${proj_dir}/packages/${pkg} || exit 1
    # See if the tag exists already
    if test ! -z $(git tag -l "v${version}"); then
        echo "Warning: tag v${version} already exists"
        git tag -d "v${version}"
        git tag -a -m "Release ${version}" "v${version}"
        git push origin --force "v${version}"
    else
        git tag -a -m "Release ${version}" "v${version}"
        git push --tags
    fi
done

