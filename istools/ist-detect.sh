#!/bin/sh
# Return list of instruction sets supported by host CPU, sorted oldest -> newest
# TODO:
# - Additional platforms (BSD?, Windows, though that would have to be PS/Bat)
# - What about multisocket machines with hetrogeneous physical CPUs...
# - Just dump caps, or filter/sort?
# Known Issues:
# - macOS/Linux report some capabilities in slight different formats
#   e.g. sse4.1/sse4_1 macOS/Linux
PLATFORM=`uname -s`

#// Trim leading/trailing whitespace
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
      exit 1
      ;;
  esac
}

echo "$(ist_trim "$(ist_get_capabilities)")"
