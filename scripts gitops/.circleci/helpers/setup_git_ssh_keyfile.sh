echo "Reading the base64 encoded git_ssh_key passed in as environment variable"
echo "and putting it in the /root/.ssh/id_rsa file"
: "${GIT_SSH_KEY_BASE64:?Need to set GIT_SSH_KEY_BASE64}"

export GIT_SSH_KEY_FILE=/root/.ssh/id_rsa
echo $GIT_SSH_KEY_BASE64 | base64 -d > $GIT_SSH_KEY_FILE
chmod 600 $GIT_SSH_KEY_FILE