
echo "Logging into docker hub using the DOCKER_REG_USERNAME and DOCKER_REG_PASSWORD environment variables"

# Default to an empty string for the docker registry if it's not provided
echo "Docker registry: ${DOCKER_REGISTRY_HOSTNAME:=quay.io}"

# Require values for these two
: "${DOCKER_REG_USERNAME:?Need to set DOCKER_REG_USERNAME}"
: "${DOCKER_REG_PASSWORD:?Need to set DOCKER_REG_PASSWORD}"

echo "running: docker login $DOCKER_REGISTRY_HOSTNAME -u $DOCKER_REG_USERNAME --password-stdin" 

echo "${DOCKER_REG_PASSWORD}" | docker login $DOCKER_REGISTRY_HOSTNAME -u $DOCKER_REG_USERNAME --password-stdin
