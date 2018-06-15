{ nixpkgs ? <nixpkgs> }:

with import nixpkgs {};

let
  clhep = callPackage ./clhep.nix {};

  # For now the upstream GEANT4 recipe is a little weird but it seems like someone is working on it:
  # https://github.com/NixOS/nixpkgs/pull/40618
  # As it is badly written it isn't available in the binary cache so this will trigger a build
  # If we're forced to build to build, then we might as well enable everything
  geant4Full = (geant4.override {
    enableMultiThreading = true;
    enableG3toG4 = true;
    enableInventor = false;
    enableGDML = true;
    enableQT = true;
    enableXM = true;
    enableOpenGLX11 = true;
    enableRaytracerX11 = true;

    clhep = clhep;
    zlib = zlib;
    expat = expat;
    xercesc = xercesc;
    motif = motif;
    qt = qt4;
    xlibsWrapper = xlibsWrapper;
    libXmu = xorg.libXmu;
  }).v10_0_2;
in
  stdenv.mkDerivation rec {
    name = "HSF_testdrive_environment";
    env = buildEnv {
      name = name;
      paths = buildInputs;
      ignoreCollisions = true;
      extraOutputsToInstall = [
        "bin" "debug" "dev" "devdoc" "doc" "info" "man" "out" "static"
      ];
    };
    buildInputs = [
      # Nix itself
      nix
      nix-prefetch-scripts

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
      gfortran
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

      ((python2.withPackages (ps: [
          ps.pip
          ps.ipython
          ps.numpy
          ps.matplotlib
        ])).override {
          # Workaround https://github.com/NixOS/nixpkgs/issues/22319
          ignoreCollisions = true;
      })

      # The test drive packages
      boost166
      gsl
      qt510.qtbase
      root
      xercesc
      clhep
      geant4Full
    ];
  }
