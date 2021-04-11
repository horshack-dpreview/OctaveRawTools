# Octave Raw Tools

Collection of Octave/Matlab functions for working with DNG raw image files, including reading, modifying, and writing the raw CFA bayer data contained in DNG raw image files.

## Installation

Download the function files of this repository into a directory. To use the functions, either create your own logic within that directory or add the directory of the raw tools to your [Octave](https://octave.org/doc/v4.0.1/Manipulating-the-Load-Path.html)/[Mablab](https://www.mathworks.com/help/matlab/ref/addpath.html) load path.

The tools require [exiftool](https://exiftool.org/). If exiftool is not in your system path then you'll want to modify the 'exiftoolPath' variable in runExiftool.m to point to where your exiftool executable lives.

## Use
See [swapRedBlueChannelsInDng.m](https://github.com/horshack-dpreview/OctaveRawTools/blob/master/swapRedBlueChannelsInDng.m) and [applyFlatFrameToDng.m](https://github.com/horshack-dpreview/OctaveRawTools/blob/master/applyFlatFrameToDng.m) for examples on how to use the tools to read, modify, and write the raw image data in DNGs. The tools only support uncompressed DNGs, which you can create using the [Adobe DNG Converter](https://helpx.adobe.com/photoshop/using/adobe-dng-converter.html). To configure the DNG converter for uncompressed, under "Compatibility" click 'Change Preferences...",  select "Custom", then click the "Uncompressed" checkbox in the Custon DNG Compatibiity dialog.
