#!/bin/bash
major_max=0;
minor_max=0;
patch_max=0;

version_output_file=$1

# Check to make sure that required values are provided
: "${component:?Need to set component}"
: "${major_version:?Need to set major_version}"
: "${minor_version:?Need to set minor_version}"


branch_name="${BRANCH_NAME}"
$(git fetch --tags)
# Get the last tag for the component
last_tag=$(git tag -l --sort=version:refname component-version/${component}/* | tail -n 1 | cut -d/ -f3)

echo "last_tag should default to 0.0.0 if not found."
echo "last_tag=${last_tag:=0.0.0}"

if [[ $last_tag ]]; then

    version=$(echo $last_tag | grep -o '[^-]*$')
    major=$(echo $version | cut -d. -f1)
    minor=$(echo $version | cut -d. -f2)
    patch=$(echo $version | cut -d. -f3)

    echo "Checking to see if major_max:${major_max} is -lt major:${major}"
    if [ "$major_max" -lt "$major" ]; then
        echo "major_max < major"
        let major_max=$major
    fi

    echo "Checking to see if minor_max:${minor_max} is -lt minor:${minor}"
    if [ "$minor_max" -lt "$minor" ]; then
        echo "minor_max < minor"
        let minor_max=$minor
    fi

    echo "Checking to see if patch_max:${patch_max} is -lt patch:${patch}"
    if [ "$patch_max" -lt "$patch" ]; then
        echo "patch_max < patch"
        let patch_max=$patch
    fi

    echo '# Adjusted Latest version:' $major_max'.'$minor_max'.'$patch_max
    let patch_max=($patch_max+1)
else
    echo "latest-sem-ver.sh unable to find the last_tag from git describe"
    exit 1
fi

echo "major_max: $major_max"
echo "minor_max: $minor_max"

if [ "$major_max" -ne "${major_version}" ] || [ "$minor_max" -ne "${minor_version}" ]; then
    major_max="${major_version}"
    minor_max="${minor_version}"
    patch_max=0
fi

new_version=$major_max'.'$minor_max'.'$patch_max

echo '# Switching to new version:' $new_version
echo "export MY_SEM_VER=$new_version"
echo $new_version > $version_output_file

# $(git tag -a $branch_name-$major_max.$minor_max.$patch_max $branch_name -m "Version $major_max.$minor_max.$patch_max")

# echo 'Push tag to remote'
# $(git push origin $branch_name-$major_max.$minor_max.$patch_max $branch_name)