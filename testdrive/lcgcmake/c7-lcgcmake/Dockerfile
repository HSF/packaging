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
      libcurl-devel         \
      libuuid-devel         \
      libXmu-devel          \
      libXpm-devel          \
      mesa-libGL-devel      \
      mesa-libGLU-devel     \
      openssl-devel         \
      readline              \
      readline-devel        \
      systemtap             \
      tk-devel              \
      tkinter               \
      unzip                 \
      wget                  \
      which

# Setup LCGCMake
RUN mkdir -p $LCGCMAKE_ROOT  && \
    git clone https://gitlab.cern.ch/sft/lcgcmake.git $LCGCMAKE_ROOT && \
    mkdir $LCGCMAKE_BUILD $LCGCMAKE_INSTALL

# Copy heptool file
COPY heptools-hsf.cmake $LCGCMAKE_ROOT/cmake/toolchain

RUN rm -f /run/nologin

RUN rm -rf /root/*.*

RUN useradd hsf

ENV USER=hsf
ENV HOME=/home/hsf
WORKDIR /home/hsf

# Alias for cmake
RUN echo 'alias cmake="cmake3"' >> ~/.bashrc

RUN chown hsf -R /build

USER hsf

CMD ["/bin/bash"]
