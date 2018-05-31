{ nixpkgs ? <nixpkgs> }:

with import nixpkgs {};

stdenv.mkDerivation rec {
  name = "HSF_testdrive_environment";
  env = buildEnv {
    name = name;
    paths = buildInputs;
    extraOutputsToInstall = [
      "bin" "debug" "dev" "devdoc" "doc" "info" "man" "out" "static"
    ];
  };
  buildInputs = [
    # Nix itself
    nix

    # Some base libraries
    autoconf
    automake
    bash
    bashInteractive
    bzip2
    cmake
    coreutils
    cpio
    cracklib
    curl
    diffutils
    ed
    elfutils
    emacs
    expat
    findutils
    fish
    gawk
    gcc
    git
    gnugrep
    gnumake
    gnused
    gnutar
    gzip
    htop
    less
    man
    patchelf
    pcre
    perl
    procps
    python
    rsync
    stdenv
    strace
    tcl
    vim
    wget
    which
    xz
    zlib
    zsh

    # The test drive packages
    boost166
    gsl
    qt510.qtbase
    root
    xercesc

    # For now the upstream GEANT4 recipe is a little weird but it seems like someone is working on it:
    # https://github.com/NixOS/nixpkgs/pull/40618
    # As it is badly written it isn't available in the binary cache so this will trigger a build
    geant4.v10_0_2
  ];
}
