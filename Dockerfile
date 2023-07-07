FROM alpine:latest

ARG env
ARG version
ARG ab_cloud_image

ENV TF_VAR_bastion_image_name=$ab_cloud_image

COPY bin /usr/local/lib/spacenode-cookbook/bin
COPY cloud/ /usr/local/lib/spacenode-cookbook/cloud
COPY src/bash/ /usr/local/lib/spacenode-cookbook/src/bash

COPY src/build/prepare-image.sh /tmp/
RUN chmod +x /tmp/prepare-image.sh \
  && /tmp/prepare-image.sh

WORKDIR /vpn
ENTRYPOINT [ "/usr/local/lib/spacenode-cookbook/bin/vs" ]
