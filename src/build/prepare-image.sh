#!/bin/bash

# Install APT packages
apt-get update && apt-get install -y \
  ca-certificates apt-transport-https iptables lsb-release gnupg \
  build-essential python2.7 python2.7-dev git curl zip

# Setup APT repo for Azure CLI
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | \
  tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
  tee /etc/apt/sources.list.d/azure-cli.list

# Setup APT repo for Google SDK
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install Azure and Google CLIs
apt-get update && apt-get install -y \
  azure-cli google-cloud-sdk

# Install pip
rm -f /usr/bin/python
ln -s /usr/bin/python3 /usr/bin/python
curl -L https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
rm get-pip.py

# Install AWS CLI
pip3 install awscli --upgrade

# Install latest version of JQ
curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq
chmod +x /usr/local/bin/jq

# Install latest version of Terraform
terraform_version=0.12.13
curl -OL https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
unzip terraform_${terraform_version}_linux_amd64.zip
mv terraform /usr/local/bin

# Compile UDP Tunnel binaries (EXPERIMENTAL)
git clone https://github.com/wangyu-/UDPspeeder.git /tmp/udp-speeder
pushd /tmp/udp-speeder
git checkout branch_libev
make
mv /tmp/udp-speeder/speederv2 /usr/local/bin/udp-speeder
popd

git clone https://github.com/wangyu-/udp2raw-tunnel.git /tmp/udp2raw-tunnel
pushd /tmp/udp2raw-tunnel
git checkout master
make
mv /tmp/udp2raw-tunnel/udp2raw /usr/local/bin/udp2raw
popd

# Download KCP tunnel server (EXPERIMENTAL)
kcp_tunnel_version=20190924

pushd /tmp
curl -L https://github.com/xtaci/kcptun/releases/download/v${kcp_tunnel_version}/kcptun-linux-amd64-${kcp_tunnel_version}.tar.gz \
  -o kcptun-linux-amd64.tgz
tar xvzf kcptun-linux-amd64.tgz
mv client_linux_amd64 /usr/local/bin/kcptun-client
popd

mkdir /vpn
rm -fr /tmp/*
