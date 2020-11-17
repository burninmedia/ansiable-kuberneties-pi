echo "Reading the base64 encoded git_ssh_key passed in as environment variable"
echo "and putting it in the /git_ssh_key file"
: "${GIT_SSH_KEY_BASE64:?Need to set GIT_SSH_KEY_BASE64}"

export GIT_SSH_KEY_FILE=/git_ssh_key
echo $GIT_SSH_KEY_BASE64 | base64 -d > $GIT_SSH_KEY_FILE