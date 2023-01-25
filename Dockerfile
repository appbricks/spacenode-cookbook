FROM alpine:latest

ARG AB_CLOUD_IMAGE
ENV TF_VAR_bastion_image_name=$AB_CLOUD_IMAGE

COPY bin /usr/local/lib/vpn-server/bin
COPY cloud/ /usr/local/lib/vpn-server/cloud
COPY src/bash/ /usr/local/lib/vpn-server/src/bash

COPY src/build/prepare-image.sh /tmp/
RUN chmod +x /tmp/prepare-image.sh \
  && /tmp/prepare-image.sh

WORKDIR /vpn
ENTRYPOINT [ "/usr/local/lib/vpn-server/bin/vs" ]
