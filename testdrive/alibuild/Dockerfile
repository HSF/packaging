FROM hepsoftwarefoundation/c7-nix

LABEL maintainer="Giulio Eulisse <giulio.eulisse@cern.ch>"

RUN nix-env -i git which && nix-env -e cmake gcc
RUN nix-channel --add https://nixos.org/channels/nixos-18.03 nixpkgs && nix-channel --update
RUN git clone https://github.com/ktf/nixpkgs-o2 &&                                  \
    mkdir -p ~/.config/nixpkgs/overlays &&                                          \
    ln -sf ~/nixpkgs-o2/o2-overlay.nix ~/.config/nixpkgs/overlays/o2-overlay.nix && \
    nix-env -iA nixpkgs.alice.o2BuildEnv

RUN git clone https://github.com/alisw/alibuild
# Hack until this gets merged mainstream
RUN git clone https://github.com/ktf/alidist -b feature-system-view
# Hack until I figure out what's wrong with cc7-nix python
RUN sed -i -e's/python -c/python3 -c/g' alidist/python-modules.sh

ENV ALIBUILD_SYSTEM_VIEW=/home/hsf/.nix-profile
