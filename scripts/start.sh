#!/bin/bash
# Copyright (c) 2023 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Test if PREFIX location is whithin limits
if [[ ! "$PREFIX" == "/usr/local" && ! "$PREFIX" =~ ^"/opt" ]]; then
  echo "ERROR:  PREFIX set to '$PREFIX'. Must either be '/usr/local' or within '/opt'."
  exit 1
fi

# Test if there is a bin folder at PREFIX
if [[ ! -d "/tmp$PREFIX/bin" ]]; then
  echo "ERROR:  There is no 'bin' folder in '$PREFIX'."
  echo "INFO:   Execute 'mkdir -p $PREFIX/bin'" to create one.
  exit 1
fi

if [[ "$MODE" == "install" ]]; then
  cabal update

  if dpkg --compare-versions "$(cabal --numeric-version)" lt "$CABAL_VERSION_MIN"; then
    # Install Cabal
    cabal install "cabal-install-$CABAL_VERSION_MIN"
    echo "Copying 'cabal' to '$(which cabal)'"
    cp -aL /root/.cabal/bin/cabal "$(which cabal)"
  fi

  # Download and extract source code
  cd /tmp
  curl -sSL https://github.com/commercialhaskell/stack/archive/refs/tags/v"$STACK_VERSION_BUILD".tar.gz \
    -o stack.tar.gz
  tar -xzf stack.tar.gz
  cd stack-*

  # Apply patch
  if [[ -f "/tmp/$STACK_VERSION_BUILD.patch" ]]; then
    patch -p0 <"/tmp/$STACK_VERSION_BUILD.patch"
  fi

  # Modify config
  sed -i /stack/d cabal.config

  # Build and install
  cabal build \
    --allow-older \
    --enable-executable-static \
    --ghc-options='-split-sections -optl=-pthread'

  strip "$(find dist-newstyle -name stack -type f)"

  cp -aL "$(find dist-newstyle -name stack -type f)" "/tmp$PREFIX/bin"
  echo "INFO:   Stack v$STACK_VERSION_BUILD installed in '$PREFIX/bin'."
elif [[ "$MODE" == "uninstall" ]]; then
  if [[ -f "/tmp$PREFIX/bin/stack" ]]; then
    rm -f "/tmp$PREFIX/bin/stack"
    echo "INFO:   Stack uninstalled from '$PREFIX/bin'."
  else
    echo "ERROR:  Stack not found in '$PREFIX/bin'!"
    exit 1
  fi
else
  echo "ERROR:  Execution mode '$MODE' not supported!"
  exit 1
fi
