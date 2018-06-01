# Based on https://github.com/spack/spack/blob/develop/share/spack/docker/spack_centos/Dockerfile
# Credits to: Omar Padron <omar.padron@kitware.com>

FROM centos:7
MAINTAINER Javier Cervantes <javier.cervantes.villanueva@cern.ch>

ENV SPACK_ROOT=/spack        \
    FORCE_UNSAFE_CONFIGURE=1 \
    DISTRO=centos

# Spack requirements
RUN yum update -y               && \
    yum install -y epel-release && \
    yum update -y               && \
    yum groupinstall -y "Development Tools" && \
    yum install -y            \
        curl                  \
        findutils             \
        gcc-c++               \
        gcc                   \
        gcc-gfortran          \
        git                   \
        gnupg2                \
        hostname              \
        iproute               \
        Lmod                  \
        make                  \
        patch                 \
        openssh-server        \
        python                \
        tcl                   \
        which              && \
    git clone --depth 1 git://github.com/spack/spack.git /spack && \
    rm -rf /spack/.git

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

RUN echo "source /usr/share/lmod/lmod/init/bash" \
    > /etc/profile.d/spack.sh
RUN echo "source /spack/share/spack/setup-env.sh" \
    >> /etc/profile.d/spack.sh
RUN echo "source /spack/share/spack/spack-completion.bash" \
    >> /etc/profile.d/spack.sh

RUN rm -f /run/nologin

RUN rm -rf /root/*.*

RUN useradd hsf

ENV USER=hsf
ENV HOME=/home/hsf
WORKDIR /home/hsf

RUN chown hsf -R /spack

USER hsf
RUN mkdir -p /home/hsf/.spack

ENTRYPOINT ["bash"]
CMD ["-l"]
