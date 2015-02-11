#!/bin/bash
VERSION=1.1
zip -9rv praatalign_$VERSION.zip align* cleaninterval.praat generatedict.p* install* LICENCE* par.* phonetizer.py pyDAWG.py set*
tar -cvf praatalign_$VERSION.tar align* cleaninterval.praat generatedict.p* install* LICENCE* par.* phonetizer.py pyDAWG.py set*
gzip -vv9c praatalign_$VERSION.tar > praatalign_$VERSION.tar.gz
bzip2 -vv9c praatalign_$VERSION.tar > praatalign_$VERSION.tar.bz2
xz -vvec praatalign_$VERSION.tar > praatalign_$VERSION.tar.xz
rm praatalign_$VERSION.tar
