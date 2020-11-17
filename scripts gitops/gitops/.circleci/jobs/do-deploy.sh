#!/bin/bash
set -e
figlet "Do deploy"

# set up the build environment
. ./.circleci/helpers/debundle-context.sh
. ./.circleci/helpers/setup_kubeconfig.sh
. ./.circleci/helpers/setup_git_user.sh
. ./.circleci/helpers/helm-check.sh

echo "Starting the deployment"

rootdir=`pwd`

project=$(echo $CIRCLE_TAG | cut -d/ -f3)
environment=$(echo $CIRCLE_TAG | cut -d/ -f4)

echo "Calling do-helm-upgrade-environments for $project, environment $environment"
cd $project
/bin/bash $rootdir/.circleci/helpers/do-helm-upgrade-environments.sh $project $environment

exit_code=$?
if [[ "$?" -ne 0 ]]; then
	status='fail'
else
	status='pass'
fi

ruby ~/project/.circleci/helpers/slack_for_deploy.rb \
"devops_platform" "${project}" "orca-gitops" "${environment}" "${status}"

figlet "SUCCESS"
