#!/bin/bash -x

version="0.0.3"

scripts_dir=$(dirname $(realpath $0))
proj_dir=$(dirname ${scripts_dir})

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
    ex_version=$(sed -e "s/VERSION=\"\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)\"/\1/g" $files)
    if test ${ex_version} != ${version}; then
        echo "Error: version mismatch: ${ex_version} != ${version}"
        exit 1
    fi
done

# Now, go through and create tags
for pkg in $packages; do
    echo "pkg: ${pkg}"
    cd ${proj_dir}/packages/${pkg} || exit 1
    git tag -a -m "Release ${version}" "v${version}" || exit 1
    git push --tags || exit 1
done

