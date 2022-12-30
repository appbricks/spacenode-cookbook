#!/bin/sh

case `uname -m` in
  x86_64)
    arch=amd64
    ;;
  aarch64_be|aarch64)
    arch=arm64
    ;;
  *)
    echo "Unsupported system architecture."
    ;;
esac

set -xeuo pipefail

# Install packages
apk update && apk upgrade
apk --no-cache add \
  build-base autoconf automake openssl-dev libffi-dev libtool \
  bison flex iptables bash curl zip git libqrencode openssh sshpass \
  python3 python3-dev py3-pip

rm -f /usr/bin/python && \
  ln -s /usr/bin/python3 /usr/bin/python

# Install AWS CLI
pip install awscli

# Install Azure CLI
pip install azure-cli

# Install Google CLI
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_INSTALL_DIR=/usr/local/lib
curl -sSL https://sdk.cloud.google.com | bash
echo "export PATH=$PATH:${CLOUDSDK_INSTALL_DIR}/google-cloud-sdk/bin" > /etc/profile.d/google-sdk.sh
ln -s ${CLOUDSDK_INSTALL_DIR}/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
ln -s ${CLOUDSDK_INSTALL_DIR}/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil

# Install latest version of Terraform
terraform_version=1.3.4
curl -OL https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_${arch}.zip
unzip terraform_${terraform_version}_linux_${arch}.zip
mv terraform /usr/local/bin

# Build latest version of JQ
git clone --branch jq-1.6 https://github.com/stedolan/jq /tmp/jq
cd /tmp/jq
git submodule update --init
autoreconf -fi
./configure --with-oniguruma=builtin
make -j8
make check
mv ./jq /usr/local/bin
cd -

# Compile UDP Tunnel binaries (EXPERIMENTAL)
git clone https://github.com/wangyu-/UDPspeeder.git /tmp/udp-speeder
cd /tmp/udp-speeder
git checkout branch_libev
make
mv /tmp/udp-speeder/speederv2 /usr/local/bin/udp-speeder
cd -

git clone https://github.com/wangyu-/udp2raw-tunnel.git /tmp/udp2raw-tunnel
cd /tmp/udp2raw-tunnel
git checkout master
make
mv /tmp/udp2raw-tunnel/udp2raw /usr/local/bin/udp2raw
cd -

# Download KCP tunnel server (EXPERIMENTAL)
kcp_tunnel_version=20221015

cd /tmp
curl -L https://github.com/xtaci/kcptun/releases/download/v${kcp_tunnel_version}/kcptun-linux-${arch}-${kcp_tunnel_version}.tar.gz \
  -o kcptun-linux-${arch}.tgz
tar xvzf kcptun-linux-${arch}.tgz
mv client_linux_${arch} /usr/local/bin/kcptun-client
cd -

mkdir /vpn
rm -fr /tmp/*
rm -rf /var/cache/apk/*
