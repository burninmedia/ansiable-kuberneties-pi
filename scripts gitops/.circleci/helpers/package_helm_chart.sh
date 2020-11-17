
# Default value that we won't typically override
helm_package_dir=helm-package

# Check Required parameters
: "${repo_url:?Need to set repo_url}"
: "${version:?Need to set version}"
: "${helm_chart_dir:?Need to set helm_chart_dir}"
: "${helm_chart_name:?Need to set helm_chart_name}"
: "${helm_package_dir:?Need to set helm_package_dir}"

figlet "helm package"
echo " repo_url         = ${repo_url}"
echo " version          = ${version}"
echo " helm_chart_dir   = ${helm_chart_dir}"
echo " helm_chart_name  = ${helm_chart_name}"
echo " helm_package_dir = ${helm_package_dir}"

# Create a directory to do the packaging in
mkdir -p ${helm_package_dir}

# Run the helm package command to package up and assign a version to the package
helm --version ${version} -d ./${helm_package_dir}/ package ${helm_chart_dir}/${helm_chart_name}

# If the repo_url starts with s3: then we will push the chart to the s3 repository
# Otherwise we will just 
if [[ $repo_url == s3:* ]]; then
	echo "repo_url begins with s3:"
	echo "helm repo add"
	helm repo add wowza $repo_url
	echo "run helm s3 push"
	helm s3 push ./${helm_package_dir}/${helm_chart_name}-${version}.tgz wowza
else
	# generate the repo index locally
	helm repo index --url ${repo_url} ./${helm_package_dir}
fi
