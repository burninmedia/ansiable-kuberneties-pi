echo "build-version-tagged-component.sh"

. ./.circleci/helpers/debundle-context.sh

. ./.circleci/helpers/docker_registry_login.sh

echo "CIRCLE_TAG=${CIRCLE_TAG}"

# The Circle tag will look like this...
# release/COMPONENT_NAME/X.Y.Z
component=`echo "${CIRCLE_TAG}" | cut -d/ -f2`
version=`echo   "${CIRCLE_TAG}" | cut -d/ -f3`

echo "component =${component}"
echo "version   =${version}"

type=$(yq r ./components.yaml ${component}.type)

# Default helm Repo to our standard S3 chart repositoriy
DEFAULT_HELM_REPO="s3://wowza-private-helm-repo/charts"
: "${HELM_REPO:=$DEFAULT_HELM_REPO}"

# Default value for AWS Region
DEFAULT_AWS_DEFAULT_REGION="us-east-1"
: "${AWS_DEFAULT_REGION:=$DEFAULT_AWS_DEFAULT_REGION}"
export AWS_DEFAULT_REGION

# Default to quay.io/wowzaprivate, unless it's set as an environment variable
DEFAULT_DOCKER_REGISTRY="quay.io/wowzaprivate"
: "${DOCKER_REGISTRY:=$DEFAULT_DOCKER_REGISTRY}"

# Make sure we have a slack webhook URL supplied
: "${SLACK_WEBHOOK_URL:?Must supply SLACK_WEBHOOK_URL}"

# Run the proper helper that builds this type of component
case "$type" in

	# If it's a helm chart component
	helm)
		version=${version} \
		helm_chart_dir=$(yq r ./components.yaml ${component}.chart_dir) \
		helm_chart_name=$(yq r ./components.yaml ${component}.chart_name) \
		repo_url=${HELM_REPO} \
		/bin/bash .circleci/helpers/package_helm_chart.sh
		;;

	# Or a docker image component
	docker)
		docker_dir=$(yq r ./components.yaml ${component}.docker_dir) \
		image=${DOCKER_REGISTRY}/$(yq r ./components.yaml ${component}.image_name) \
		version=${version} \
		/bin/bash .circleci/helpers/docker_build_push.sh
		;;

	source-tag-only)
		echo "Nothing to do here, the $component component is simply tagged with version $version"
		;;
esac

exit_code=$?
if [[ "$?" -ne 0 ]]; then
	status='fail'
else
	status='pass'
fi

ruby ~/project/.circleci/helpers/slack_for_build.rb \
"devops_platform" "${component}" "orca" "${version}" "${status}"


# todo add the auto update gitops stuff

      # # # Updates the QA deployment to use this new version
      # - >
      #   git_host=git@github.com:wowza-private
      #   git_repo=yeti-gitops
      #   git_sub_dir=environments/non-prod/wowza-qa-1
      #   project=blueprint-api
      #   version_varname=version
      #   version=${VERSION}
      #   /bin/bash .circleci/helpers/auto_update_gitops.sh