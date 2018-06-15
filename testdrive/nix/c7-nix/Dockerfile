# Install nix into a base CentOS7 image
FROM centos:7
LABEL maintainer="Graeme Stewart <graeme.andrew.stewart@cern.ch>"

# First some prerequisites - namely curl to get the nix
# installer and bzip2 to unpack it
RUN yum -y install curl bzip2 sudo

# Now add an hsf user (passwd hsf), with sudo rights
RUN useradd -G wheel -p '$6$JmsT1xYM$CdWIKb6aHhqWniaanWDq1Hi9qF4pXJlmsSHrqDDjF8CsYG3w8WyTO4/.xBnG71Zx1aROZ.S.ZoR2BARuB4QBN1' hsf
COPY sudoers /etc/suoders
# Pre-create the /nix area because here we install as a single user
RUN mkdir -m 0755 /nix && chown hsf /nix

# Copy a nix expression that is used to define the environment
COPY testdrive_environment.nix clhep.nix /home/hsf/
# COPY geant4 /home/hsf/geant4
RUN chown -R hsf /home/hsf && chgrp -R hsf /home/hsf

# Install nix
USER hsf
ENV USER=hsf \
    HOME=/home/hsf
WORKDIR /home/hsf
RUN curl https://nixos.org/nix/install | bash

# Bootstrap the nix environment
ENV PATH=/home/hsf/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/hsf/.local/bin:/home/hsf/bin \
    NIX_PATH=nixpkgs=/home/hsf/.nix-defexpr/channels/nixpkgs \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt

# Change from the default unstable channel to 18.03 (last release, April 2018)
RUN nix-channel --remove nixpkgs && \
    nix-channel --add https://nixos.org/channels/nixos-18.03 nixpkgs && \
    nix-channel --update

# Install the test drive environment in the default location
RUN nix-env -ir -f /home/hsf/testdrive_environment.nix -A env

# By default launch the test drive environment using nix shell
# This sets up the environment variables which is the "official" way of using Nix
# For deployment we could either:
#    - source a script to initialise an identical environment
#    - add support for discovering the install location (multiple options are available)
CMD ["nix-shell", "--pure", "--command", "export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt; return", "/home/hsf/testdrive_environment.nix"]
