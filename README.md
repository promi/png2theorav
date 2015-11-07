# png2theorav - create theora videos from png files

This is a Vala rewrite of the original example tool written in C from
Xiph.Org's theora:

https://git.xiph.org/?p=theora.git;a=blob;f=examples/png2theora.c;h=c740ad8043848738909c09b07135d7cedb9e5fff;hb=HEAD

Changes are

- VAPI files for libtheora, libogg and libpng
- Replaced return code based error handling by exception handling
- Rewrote command line parsing from getopt to GLib OptionGroup
- Reorganized the code into several classes
- Replaced stdio file functions by gio classes
- Added some additional error handling

Licensing

The original work is under a BSD license (see COPYING), the derived work
is released under the AGPLv3 license (see COPYING-AGPLv3).

