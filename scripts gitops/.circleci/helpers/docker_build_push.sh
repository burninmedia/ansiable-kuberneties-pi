

# Default value that we won't typically override.


# Check required values
: "${docker_dir:?Need to set docker_dir}"
: "${image:?Need to set image}"
: "${version:?Need to set version}"

figlet "docker build / push"

echo " docker_dir = ${docker_dir}"
echo " image      = ${image}"
echo " version    = ${version}"

cd ${docker_dir}
docker build -t ${image}:${version} .
docker push ${image}:${version}