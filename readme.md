
# Octave Raw Tools

Collection of Octave/Matlab functions for working with DNG raw image files, including reading, modifying, and writing the raw CFA bayer data contained in DNG raw image files.

## Installation

Download the function files of this repository into a directory. To use the functions, either create your own logic within that directory or add the directory of the raw tools to your [Octave](https://octave.org/doc/v4.0.1/Manipulating-the-Load-Path.html)/[Mablab](https://www.mathworks.com/help/matlab/ref/addpath.html) load path.

The tools require [exiftool](https://exiftool.org/). If exiftool is not in your system path then you'll want to modify the 'exiftoolPath' variable in runExiftool.m to point to where your exiftool executable lives.

## Use
See [swapRedBlueChannelsInDng.m](https://github.com/horshack-dpreview/OctaveRawTools/blob/master/swapRedBlueChannelsInDng.m) and [applyFlatFrameToDng.m](https://github.com/horshack-dpreview/OctaveRawTools/blob/master/applyFlatFrameToDng.m) for examples on how to use the tools to read, modify, and write the raw image data in DNGs. The tools only support uncompressed DNGs, which you can create using the [Adobe DNG Converter](https://helpx.adobe.com/photoshop/using/adobe-dng-converter.html). To configure the DNG converter for uncompressed, under "Compatibility" click 'Change Preferences...",  select "Custom", then click the "Uncompressed" checkbox in the Custon DNG Compatibiity dialog.

## Raw Median Stacker
Here's a getting-started guide on the Raw Median Stacker, including information for those new to Octave.

### Tools Required
1. [Octave (Windows)](https://www.gnu.org/software/octave/download#ms-windows) / [Octave (Mac OSX)](https://octave-app.org/Download.html)
2. [Adobe's DNG Converter](https://helpx.adobe.com/photoshop/using/adobe-dng-converter.html)
3. [exiftool](https://exiftool.org/)

### Steps
1. Download the OctaveRawTools scripts (this project). You can download them directly [here](https://github.com/horshack-dpreview/OctaveRawTools/archive/refs/heads/master.zip) or, if you're familiar with git, perform a **git clone https://github.com/horshack-dpreview/OctaveRawTools** inside a command/terminal window.
2. Run Octave.
3. Set Octave's starting directory to the folder you downloaded the OctaveRawTools into. Do this by going to Preferences -> General tab, "Octave Startup" at bottom of dialog and browsing to the folder containing the OctaveRawTools scripts. Press OK. Restart Octave so it uses the new startup directory.
4. Locate the Octave "Command Window". It may be hidden in one of the tabbed windows. If you don't see it, click Window -> Show Command Window
5. To run the script, type: **createMedianStackedDngs("source dir", output dir")** (*quotes included in case your paths have spaces in them*), where "source dir" is the directory containing the raw files you want to stack and "output dir" where you want the stacked files to be written. If "source dir" contains only raw files then you don't need to include a file mask. However, if there are other types of files in the directory, including hidden files like .DS_Store for OSX, then you'll need to specify a file mask as part of the source dir. For example, **/Users/YourName/myimages/*.ARW**. Note the mask is case-sensitive, so be sure to match the case of the extension to that of your raw files.
