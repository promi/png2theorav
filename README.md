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

Usage:
  png2theorav [OPTION...] INPUT - create theora movie from png files

The INPUT argument uses C printf format to represent a list of files, i.e. file-%%06d.png to look for files file000001.png to file9999999.png

Help Options:
  -h, --help                          Show help options

Application Options:
  -o, --output=FILE                   file name for encoded output (required);
  -v, --video-quality=INT             Theora quality selector from 0 to 10 (0 yields smallest files but lowest video quality. 10 yields highest fidelity but large files)
  -V, --video-rate-target=DOUBLE      bitrate target for Theora video (kB)
  --soft-target                       Use a large reservoir and treat the rate as a soft target; rate control is less strict but resulting quality is usually higher/smoother overall. Soft target also allows an optional -v setting to specify a minimum allowed quality.
  --single-pass                       Single pass (default).
  --two-pass                          Compress input using two-pass rate control. This option performs both passes automatically.
  --first-pass=FILE                   Perform first-pass of a two-pass rate controlled encoding, saving pass data to FILE for a later second pass
  --second-pass=FILE                  Perform second-pass of a two-pass rate controlled encoding, reading first-pass data from FILE. The first pass data must come from a first encoding pass using identical input video to work properly.
  -k, --keyframe-freq=INT             Keyframe frequency
  -d, --buf-delay=INT                 Buffer delay (in frames). Longer delays allow smoother rate adaptation and provide better overall quality, but require more client side buffering and add latency. The default value is the keyframe interval for one-pass encoding (or somewhat larger if --soft-target is used) and infinite for two-pass encoding.
  --chroma-444                        Use 4:4:4 chroma subsampling
  --chroma-422                        Use 4:2:2 chroma subsampling
  --chroma-420                        Use 4:2:0 chroma subsampling (default)
  -s, --aspect-numerator=INT          Aspect ratio numerator, default is 0
  -S, --aspect-denominator=INT        Aspect ratio denominator, default is 0
  -f, --framerate-numerator=INT       Frame rate numerator, default is 24
  -F, --framerate-denominator=INT     Frame rate denominator, default is 1. The frame rate numerator  divided by this determines the frame rate in units per tick
  -c, --vp3-compatible                

