#!/bin/sh

##
# A script to convert minified barcode images to resolutions suitable for
# printing. Requires Unix-like environment and ImageMagick.
##


:<<LICENSE

Copyright (c) 2012 Joseph Howse

This software is provided 'as-is', without any express or implied warranty. In
no event will the author be held liable for any damages arising from the use
of this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim
that you wrote the original software. If you use this software in a product,
an acknowledgment in the product documentation would be appreciated but is
not required.
2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

Joseph Howse
josephhowse@nummist.com

LICENSE


SRC=$(dirname $0)/Minified
DST=$(dirname $0)/Printable

for FILE in `ls $SRC/SimpleThin`
do
  # Source is 8px wide, including 1px border.
  # Convert @72 dpi to 80mm wide, including 10mm border.
  convert $SRC/SimpleThin/$FILE -sample 2800% $DST/SimpleThin/$FILE
done

for FILE in `ls $SRC/BchThin`
do
  # Source is 8px wide, including 1px border.
  # Convert @72 dpi to 80mm wide, including 10mm border.
  convert $SRC/BchThin/$FILE -sample 2800% $DST/BchThin/$FILE
done

for FILE in `ls $SRC/FrameThin`
do
  # Source is 22px wide, including 1px border.
  # Convert @72 dpi to 100mm wide, including 4.545mm border.
  convert $SRC/FrameThin/$FILE -sample 1300% $DST/FrameThin/$FILE
done