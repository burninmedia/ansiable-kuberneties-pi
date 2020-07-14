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
WORKDIR /workdir
COPY . ./
RUN mv .bashrc .ssh /root && chmod -R go-rwx /root/.ssh
