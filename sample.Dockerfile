ARG IMAGE
ARG GHC_VERSION

FROM ${IMAGE}:${GHC_VERSION}

COPY scripts/*.sh /usr/bin/

CMD ["start.sh"]
