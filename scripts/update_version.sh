#!/bin/bash -x

version="0.0.7"

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
    ex_version=$(sed -e 's/BASE="\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)"/\1/g' $files)
    if test ${ex_version} = ${version}; then
        echo "Warning: project already has verison ${version}"
    else
        sed -i -e "s/BASE=\"[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\"/BASE=\"${version}\"/g" $files
        git add $files || exit 1
        git commit -s -m "Update version to ${version}" || exit 1
        git push || exit 1
    fi
done

