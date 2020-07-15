#! /bin/bash
set -e
# set -u
set -o pipefail

echo "Arguments: $@"
while getopts ":p:" opt; do
  case ${opt} in
    p ) # process option p
        echo $OPTARG
        export SSHPASS=$OPTARG
      ;;
    \? )
        echo "Invalid Option: -$OPTARG" 1>&2
        exit 1
      ;;
  esac
done
shift $((OPTIND -1))

for var in "$@"
do
    sshpass -e ssh pi@${var} mkdir -p /home/pi/.ssh
    sshpass -e ssh pi@${var} touch /home/pi/.ssh/authorized_keys
    sshpass -e ssh pi@${var} chmod 600 /home/pi/.ssh/authorized_keys
    sshpass -e scp ./ssh_key.pub pi@${var}:/home/pi/.ssh/authorized_keys
    echo "pub key copied to ${var}"
done
unset SSHPASS