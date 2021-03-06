#!/bin/bash
#
# Recursive swift code wrapper generator for gobject-introspection (.gir) files.
# This calls the non-recursive gir-to-swift.sh to do the heavy lifting.
#
. ./config.sh
./package.sh fetch
if ! pushd .build/gir2swift >/dev/null 2>&1 ; then
	mkdir -p .build
	pushd .build >/dev/null
	git clone https://github.com/rhx/gir2swift.git
	cd gir2swift && ./build.sh
fi
export PATH=`pwd`/.build/debug:${PATH}
popd >/dev/null
if which parallel >/dev/null ; then
  for gen in Packages/*/gir-to-swift.sh ; do \
	echo echo \"Generate Swift Wrapper for `dirname $gen | cut -d/ -f2`\" \; \
	"( cd `dirname $gen` && ./`basename $gen` $@ )" ; \
  done | $TAC | parallel
else
  for gen in Packages/*/gir-to-swift.sh ; do
	echo "Generate Swift Wrapper for `dirname $gen | cut -d/ -f2`"
	( cd `dirname $gen` && ./`basename $gen` "$@" )
  done
fi
