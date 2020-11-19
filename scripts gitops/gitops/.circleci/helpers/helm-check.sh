printf "Testing cluster access...  "

# Get cluster info
figlet "cluster-info"
kubectl cluster-info

# Check Helm Version
figlet "helm version"
helm version --debug --tiller-connection-timeout 90

printf "Done\n\n"

