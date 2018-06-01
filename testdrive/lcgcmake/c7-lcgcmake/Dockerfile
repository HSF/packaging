FROM centos:7
MAINTAINER Javier Cervantes <javier.cervantes@cern.ch>

ENV LCGCMAKE_ROOT=/build/lcgcmake            \
    LCGCMAKE_BUILD=/build/lcgcmake-build     \
    LCGCMAKE_INSTALL=/build/lcgcmake-install \
    ARCH=x86_64


# Install base requirements (extracted from Puppet configuration)
RUN yum update -y                           && \
    yum install -y epel-release             && \
    yum update -y                           && \
    yum groupinstall -y "Development Tools" && \
    yum install -y          \
      autoconf              \
      automake              \
      bzip2                 \
      bzip2-devel           \
      cmake3                \
      curl                  \
      expat                 \
      expat-devel           \
      gdbm-devel            \
      git                   \
      glibc-devel           \
      HEP_OSlibs            \
      java                  \
      libcurl-devel         \
      libICE-devel          \
      libuuid-devel         \
      libXmu-devel          \
      libXpm-devel          \
      libxslt-devel         \
      mesa-libGL-devel      \
      mesa-libGLU-devel     \
      motif-devel           \
      MySQL-python          \
      openssh-server        \
      openssl-devel         \
      readline              \
      readline-devel        \
      screen                \
      subversion            \
      systemtap             \
      tk-devel              \
      tkinter               \
      unzip                 \
      wget                  \
      which                 \
      xerces-c              \
      xerces-c-devel

# Alias for cmake
RUN alias cmake='cmake3'

# Setup LCGCMake
RUN mkdir -p $LCGCMAKE_ROOT  && \
    git clone https://gitlab.cern.ch/sft/lcgcmake.git $LCGCMAKE_ROOT && \
    mkdir $LCGCMAKE_BUILD $LCGCMAKE_INSTALL

RUN rm -f /run/nologin

RUN rm -rf /root/*.*

RUN useradd hsf

ENV USER=hsf
ENV HOME=/home/hsf
WORKDIR /home/hsf

RUN chown hsf -R /build

USER hsf

CMD ["/bin/bash"]
