#!/bin/sh
# Return list of instruction sets supported by host CPU, sorted oldest -> newest
# Known instruction sets, from oldest to newest are (from Table 13.1 in
# http://www.agner.org/optimize/optimizing_cpp.pdf):
#
# - 80386
# - SSE
# - SSE2
# - SSE3
# - SSSE3
# - SSE4.1
# - SSE4.2
# - AVX
# - AVX2
# - FMA3
# - AVX-512
#
# Instructions sets are backward compatible, so code compiled with, e.g. SSE3, will
# run on a platform supporting that instruction set or newer.
# TODO:
# - Additional platforms (BSD?, Windows, though that would have to be PS/Bat)
# - What about multisocket machines with hetrogeneous physical CPUs...
# - Need "standard format" for caps, as macOS/Linux report some capabilities in slight different formats
#   e.g. sse4.1/sse4_1 macOS/Linux
# - Confirm that methods for getting capabilities always return
#   them in oldest -> newest order

#// Globals
PLATFORM=`uname -s`

#// Trim leading/trailing whitespace from input string
ist_trim()
{
  echo $1 | sed 's/^ *//; s/ *$//'
}

#// return list of CPU capabilities
ist_get_capabilities() 
{
  case "$PLATFORM" in
    Darwin)
      sysctl -a \
        | grep machdep.cpu.features \
        | cut -d: -f2 \
        | tr '[A-Z]' '[a-z]' # macOS gives caps in UC
      ;;
    Linux)
      cat /proc/cpuinfo \
        | grep flags \
        | cut -d: -f2 \
        | uniq # reduces to one set, doesn't consider hetrogeneous multisocket
      ;;
    *)
      # TODO: Better error handling
      echo "[`basename $0`]: unsupported platform '$PLATFORM'" 1>&2
      exit 1
      ;;
  esac
}

# // return list of SIMD capabilities from oldest to newest
# Output of features *appear* to be oldest -> newest, so try dumb filter
# NB: gives raw platform dependent flags.
ist_get_simd_capabilities()
{
  caps=`ist_get_capabilities`
  isets=""
  for i in `ist_get_capabilities` ; do
    case $i in
      sse*|ssse*)
        isets="$isets $i"
        ;;
      avx*)
        isets="$isets $i"
        ;;
      fma*)
        isets="$isets $i"
        ;;
      *)
        ;;
    esac
  done

  echo `ist_trim "$isets"`
}

# - Basic user interface
ist_usage()
{
  cat <<EOF
Usage: ist-detect [OPTION]

Supported values for OPTION are:

  --all-capabilities     print all CPU capabilities of this host
  --simd-capabilities    print all SIMD capabilities of this host
  --help                 display this help and exit

EOF

  exit $1
}

# No arguments is an error
if test $# -eq 0; then
  ist_usage 1
else
  # Process args
  while test $# -gt 0 ; do
    case $1 in
      --all-capabilities)
        echo `ist_get_capabilities`
        ;;
      --simd-capabilities)
        echo `ist_get_simd_capabilities`
        ;;
      --help)
        ist_usage 0
        ;;
      *)
        echo "[`basename $0`]: Unknown argument '$1'" 1>&2
        ist_usage 1
        ;;
    esac
    shift
  done
fi

exit 0

