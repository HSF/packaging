{ stdenv, fetchgit, cmake }:

let
  version = "2.1.3.1";
  name = "clhep-${version}";
in stdenv.mkDerivation {
  inherit name;

  src = fetchgit {
    url = "https://gitlab.cern.ch/CLHEP/CLHEP.git";
    rev = "45ad2464329e4495b61b733a1cd95debefda411a";
    sha256 = "16wr28bprj4l93fr1q9b9ycvqi4a6jx7ynmh2wv0m65rcr0wmhrq";
  };

  buildInputs = [ cmake ];

  enableParallelBuilding = true;
  # This isn't needed for newer versions of CLHEP
  dontFixCmake = true;
  dontUseCmakeBuildDir = true;
  preConfigure = ''
    fixCmakeFiles .
    mkdir -p ../build
    cmakeDir="$PWD"
    cd ../build
  '';

  meta = {
    homepage = https://proj-clhep.web.cern.ch/proj-clhep/;
    description = "A Class Library for High Energy Physics";
    license = stdenv.lib.licenses.lgpl3;
    platforms = stdenv.lib.platforms.all;
  };
}
