FROM ubuntu:bionic
RUN apt-get update
RUN apt-get install --yes make software-properties-common
RUN apt-add-repository --yes --update ppa:ansible/ansible
RUN apt-get install --yes ansible
RUN apt-get install --yes apt-transport-https curl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install --yes kubectl
RUN apt-get install --yes python
RUN apt-get install --yes wget
RUN mkdir -p /etc/bash_completion.d
RUN apt-get install --yes bash-completion
RUN apt-get install --yes vim

WORKDIR /tmp
RUN wget https://get.helm.sh/helm-v3.3.0-rc.1-linux-amd64.tar.gz
RUN tar xfv helm-v3.3.0-rc.1-linux-amd64.tar.gz
RUN cp ./linux-amd64/helm /usr/local/bin/helm
RUN rm helm-v3.3.0-rc.1-linux-amd64.tar.gz
RUN touch /root/run-first.sh
RUN chmod +x /root/run-first.sh
RUN echo "#! /bin/bash" >> /root/run-first.sh
RUN echo "echo 'source /usr/share/bash-completion/bash_completion' >> /root/.bashrc" >> /root/run-first.sh
RUN echo "echo 'source <(kubectl completion bash)' >> /root/.bashrc" >> /root/run-first.sh
RUN echo "/bin/bash $1" >> /root/run-first.sh
RUN kubectl completion bash >/etc/bash_completion.d/kubectl

WORKDIR /workdir
COPY . ./
RUN mv .bashrc .ssh /root && chmod -R go-rwx /root/.ssh
