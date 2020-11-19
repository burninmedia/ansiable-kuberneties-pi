# Default value that we won't typically override.
git_sandbox_dir=/apply-latest-semver-tag-gitsource

: "${git_host:?Need to set git_host}"
: "${git_repo_name:?Need to set git_repo_name}"
# : "${git_hash:?Need to set git_hash}"
# : "${git_branch:?Need to set git_branch}"
: "${lsv_script:?Need to set lsv_script}"
: "${major_version:?Need to set major_version}"
: "${minor_version:?Need to set minor_version}"
: "${component:?Need to set component}"
: "${buildType:?Need to set buildType}"
: "${ssh_keyfile:?Need to set ssh_keyfile}"


figlet "apply semver"
echo " git_host      = ${git_host}"
echo " git_repo_name = ${git_repo_name}"
echo " git_hash      = ${git_hash}"
echo " git_branch    = ${git_branch}"
echo " lsv_script    = ${lsv_script}"
echo " major_version = ${major_version}"
echo " minor_version = ${minor_version}"
echo " component     = ${component}"
echo " buildType     = ${buildType}"
echo " ssh_keyfile    = ${ssh_keyfile}"

# if git_has is provided, we actually want to empty out the git_branch value
# since a hash is more specific it overrides the git_branch
if [[ -z "${git_hash}" ]]; then
	echo "git_hash is empty"
	if [[ -z "${git_branch}" ]]; then
		# if both of these are empty, we have a problem, we should exit
		echo "git_branch is empty"
		exit 1
	fi
fi

git_branch_arg="-b"

if [[ ! -z "${git_hash}" ]]; then
	git_branch=""
	git_branch_arg=""
	echo "--- git_branch erased because git_hash not empty! ---"
	echo " git_branch    = ${git_branch}"
fi

# In truth, we don't really care about git_branch so much in this script right now...

# Change into our sandbox dir
mkdir -p ${git_sandbox_dir}
cd ${git_sandbox_dir}

# Clone the gitrepo that we want to apply a tag to
echo "git clone ${git_host}/${git_repo_name}.git"
git clone ${git_host}/${git_repo_name}.git


new_version_file=${git_sandbox_dir}/${git_repo_name}.version


cd ${git_repo_name}
# this script looks at the repo and generates the next new_semver (relies on some ENV VARS)
major_version=${major_version} \
minor_version=${minor_version} \
component=${component} \
/bin/bash ${lsv_script} $new_version_file

# Export the value of new_version to
new_version=$(cat $new_version_file)

new_tag="component-version/${component}/${new_version}"

git checkout "start-component-build/${component}"

echo "git tag -a $new_tag -m "'"'"Tagged By apply-latest-semver-tag.sh"'"'" ${git_hash}"
git tag -a $new_tag -m "Tagged By apply-latest-semver-tag.sh" ${git_hash}
ssh-agent bash -c "ssh-add ${ssh_keyfile}; git push --tags"
