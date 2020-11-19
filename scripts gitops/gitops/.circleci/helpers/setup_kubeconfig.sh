printf "Reading the base64 encoded kubeconfig passed in as environment variable"
printf "and putting it in the /kubeconfig file...  "

: "${KUBECONFIG_BASE64:?Need to set KUBECONFIG_BASE64}"

#echo $KUBECONFIG_BASE64
echo $KUBECONFIG_BASE64 | base64 -d > /kubeconfig
export KUBECONFIG=/kubeconfig

printf "Done\n\n"