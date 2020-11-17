echo "start-component-build.sh"

set -e

. ./.circleci/helpers/debundle-context.sh

. ./.circleci/helpers/setup_git_user.sh

. ./.circleci/helpers/setup_git_ssh_keyfile.sh

# Gather information about the git repo to build some
# key environment variables to be used as defaults
GIT_REMOTE_URL=$(git remote get-url origin)
DEFAULT_GIT_HOST=$(echo "${GIT_REMOTE_URL}" | cut -d/ -f1)
DEFAULT_PROJECT=$(echo "${GIT_REMOTE_URL}" | cut -d/ -f2 | cut -d. -f1)

# Check for Required Variables
: "${GIT_HOST:=$DEFAULT_GIT_HOST}"
: "${PROJECT:=$DEFAULT_PROJECT}"
: "${CIRCLE_TAG:?Must Supply CIRCLE_TAG env var}"

echo "CIRCLE_BRANCH=${CIRCLE_BRANCH}"

# Break Up the CIRCLE_TAG
echo "CIRCLE_TAG=${CIRCLE_TAG}"

# The Circle tag will look like this...
# start-component-build/COMPONENT_NAME
component=`echo "${CIRCLE_TAG}" | cut -d/ -f2`
buildType=`echo "${CIRCLE_TAG}" | cut -d/ -f3`
unts=`echo "${CIRCLE_TAG}" | cut -d/ -f4`

echo "component = ${component}"
echo "buildType = ${buildType}"
echo "unts      = ${unts}"

git_host=${GIT_HOST} \
git_repo_name=${PROJECT} \
git_hash="${CIRCLE_SHA1}" \
git_branch="${CIRCLE_BRANCH}" \
lsv_script=${PWD}/.circleci/helpers/latest-component-sem-ver.sh \
major_version=$(yq r ./components.yaml ${component}.major_version) \
minor_version=$(yq r ./components.yaml ${component}.minor_version) \
component=${component} \
buildType=${buildType} \
ssh_keyfile=${GIT_SSH_KEY_FILE} \
/bin/bash ./.circleci/helpers/apply-latest-semver-tag.sh
