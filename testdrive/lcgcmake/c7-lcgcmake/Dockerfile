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
      #java                  \
      libcurl-devel         \
      #libICE-devel          \
      libuuid-devel         \
      libXmu-devel          \
      libXpm-devel          \
      #libxslt-devel         \
      mesa-libGL-devel      \
      mesa-libGLU-devel     \
      motif-devel           \
      #MySQL-python          \
      #openssh-server        \
      openssl-devel         \
      python-devel	    \
      readline              \
      readline-devel        \
      #screen                \
      #subversion            \
      systemtap             \
      tk-devel              \
      tkinter               \
      unzip                 \
      wget                  \
      which                 
      #xerces-c              \
      #xerces-c-devel

# SL7 software collection requirements
RUN yum install -y centos-release-scl-rh   && \
    yum install -y --setopt=tsflags=nodocs    \
        llvm-toolset-7                        \
        devtoolset-6-gcc                      \
        devtoolset-6-gcc-c++                  \
        devtoolset-6-gcc-gfortran             \
        devtoolset-6-gdb                   && \
    rpm -V                                    \
        llvm-toolset-7                        \
        devtoolset-6-gcc                      \
        devtoolset-6-gcc-c++                  \
        devtoolset-6-gcc-gfortran             \
        devtoolset-6-gdb                   && \
    rm -rf /var/cache/yum && yum clean all -y


# Setup LCGCMake
RUN mkdir -p $LCGCMAKE_ROOT  && \
    git clone -b hsf-test https://gitlab.cern.ch/sft/lcgcmake.git $LCGCMAKE_ROOT && \
    mkdir $LCGCMAKE_BUILD $LCGCMAKE_INSTALL

# Copy heptool file
# COPY heptools-hsf.cmake $LCGCMAKE_ROOT/cmake/toolchain

RUN rm -f /run/nologin

RUN rm -rf /root/*.*

RUN useradd hsf

ENV USER=hsf
ENV HOME=/home/hsf
WORKDIR $LCGCMAKE_BUILD

RUN mkdir /local
COPY lcgcmake-wrapper /local/lcgcmake
RUN chmod +x+w /local/lcgcmake

RUN echo 'alias cmake="cmake3"' >> /home/hsf/.bashrc
RUN echo 'export SHELL=/bin/bash' >> /home/hsf/.bashrc
RUN echo 'export PATH=/local:$PATH' >> /home/hsf/.bashrc

RUN chown hsf -R /build

USER hsf

