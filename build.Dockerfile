ARG IMAGE
ARG GHC_VERSION
ARG PREFIX=/usr/local

FROM ${IMAGE}:${GHC_VERSION} as builder

ARG CABAL_VERSION_MIN
ARG STACK_VERSION_BUILD
ARG PREFIX
ARG MODE=install

COPY scripts/*.sh /usr/bin/

RUN mkdir -p "/tmp$PREFIX/bin" \
 && start.sh

FROM scratch

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/commercialhaskell/ssi" \
      org.opencontainers.image.vendor="Olivier Benz" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG PREFIX

COPY --from=builder "/tmp$PREFIX/bin/stack" "$PREFIX/bin/stack"
