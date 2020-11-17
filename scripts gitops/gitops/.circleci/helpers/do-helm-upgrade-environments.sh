# Default variables
set -e

kubeconfig=/kubeconfig
helm_repo_url="s3://wowza-private-helm-repo/charts"
helm_repo_alias=wowza

project=$1
environment=$2

#Get/generate some of our vars
chart_name=$(yq r ./values.env.${environment}.yaml helm_chart_name)
if [[ "$chart_name" == "null" ]]; then
  chart_name=$(yq r ./values.all-environments.yaml helm_chart_name)
fi
namespace="${chart_name}-${environment}"
release_name="${environment}"
version=$(yq r ./values.env.${environment}.yaml helm_chart_version)
if [[ "$version" == "null" ]]; then
  echo "Error: Must provide helm_chart_version in values.env.${environment}.yaml"
  exit 1
fi

figlet "helm upgrade - $project"
echo " project       = ${project}"
echo " release_name  = ${release_name}"
echo " chart_name    = ${chart_name}"
echo " version       = ${version}"
echo " namespace     = ${namespace}"
echo " kubeconfig    = ${kubeconfig}"
echo " helm_repo_url = ${helm_repo_url}"


helm repo add ${helm_repo_alias} ${helm_repo_url}

figlet "fetch the helm chart"

helm fetch \
  --version ${version} \
  ${helm_repo_alias}/${chart_name} \
  2>&1

# Get values files required for below commands
if [[ -e values.all-environments.yaml ]]; then
  values_files="-f values.all-environments.yaml"
fi

values_files="${values_files} -f values.env.${environment}.yaml"

figlet "helm template"

template_cmd="helm template \
  ${values_files} \
  --namespace=${namespace} \
  --debug --kubeconfig=${kubeconfig} \
  ${chart_name}-${version}.tgz \
  2>&1"
echo $template_cmd
eval $template_cmd

figlet "helm upgrade"


upgrade_cmd="helm upgrade ${namespace} ${helm_repo_alias}/${chart_name} \
  -i --version ${version} \
  ${values_files} \
  --namespace=${namespace} \
  --debug --kubeconfig=${kubeconfig} \
  2>&1"
echo $upgrade_cmd
eval $upgrade_cmd

echo "Finished upgrading $namespace to $version"
version=""
