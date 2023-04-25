FROM alpine:latest

ARG env
ARG ab_cloud_image
ENV TF_VAR_bastion_image_name=$ab_cloud_image

COPY bin /usr/local/lib/vpn-server/bin
COPY cloud/ /usr/local/lib/vpn-server/cloud
COPY src/bash/ /usr/local/lib/vpn-server/src/bash

COPY src/build/prepare-image.sh /tmp/
RUN chmod +x /tmp/prepare-image.sh \
  && /tmp/prepare-image.sh

WORKDIR /vpn
ENTRYPOINT [ "/usr/local/lib/vpn-server/bin/vs" ]
