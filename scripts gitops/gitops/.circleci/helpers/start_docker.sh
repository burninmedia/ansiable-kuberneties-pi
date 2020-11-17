# These commands were copied from AWS doc
nohup /usr/local/bin/dockerd --host=unix:///var/run/docker.sock --host=tcp://127.0.0.1:2375 --storage-driver=overlay&

timeout 15 sh -c "until docker info; do echo .; sleep 1; done"
