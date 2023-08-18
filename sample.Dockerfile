ARG IMAGE
ARG GHC_VERSION

FROM ${IMAGE}:${GHC_VERSION}

COPY patches/*.patch /tmp/
COPY scripts/*.sh /usr/bin/

CMD ["start.sh"]
