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
RUN mkdir -m 0755 /nix
RUN chown hsf /nix
USER hsf
ENV USER=hsf
ENV HOME=/home/hsf
WORKDIR /home/hsf
RUN curl -O https://nixos.org/nix/install
RUN bash < install

# Bootstrap the nix environment 
ENV PATH=/home/hsf/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/hsf/.local/bin:/home/hsf/bin
ENV NIX_PATH=nixpkgs=/home/hsf/.nix-defexpr/channels/nixpkgs
ENV NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt

# Change from the default unstable channel to 18.03 (last release, April 2018)
RUN nix-channel --remove nixpkgs
RUN nix-channel --add https://nixos.org/channels/nixos-18.03 nixpkgs
RUN nix-channel --update

# Now install a few basic nix packages, as a development bootstrap
RUN nix-env -i -f '<nixpkgs>' \
    -A autoconf \
    -A automake \
    -A bashInteractive \
    -A bzip2 \
    -A cmake \
    -A coreutils \
    -A cpio \
    -A cracklib \
    -A curl \
    -A diffutils \
    -A ed \
    -A elfutils \
    -A expat \
    -A findutils \
    -A gawk \
    -A gcc \
    -A git \
    -A gnugrep \
    -A gnumake \
    -A gnused \
    -A gzip \
    -A less \
    -A man \
    -A pcre \
    -A perl \
    -A python \
    -A rsync \
    -A strace \
    -A tcl \
    -A vim \
    -A wget \
    -A which \
    -A xz \
    -A zlib \
    -A zsh

# Install the toolchain
RUN nix-env -i -f '<nixpkgs>' \
    -A boost166 \
    -A gsl \
    -A qt510.qtbase \
    -A root \
    -A xercesc

# For now the upstream GEANT4 recipe is a little weird but it seems like someone is working on it:
# https://github.com/NixOS/nixpkgs/pull/40618
# As it is badly written it isn't available in the binary cache so this will trigger a build
RUN nix-env -i -f '<nixpkgs>' -A geant4.v10_0_2

ENTRYPOINT ["/home/hsf/.nix-profile/bin/bash"]
CMD ["-l"]
