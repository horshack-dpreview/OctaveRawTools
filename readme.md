


# Octave Raw Tools

Collection of Octave/Matlab functions for working with DNG raw image files, including reading, modifying, and writing the raw CFA bayer data contained in DNG raw image files.

## Installation

Download the function files of this repository into a directory. To use the functions, either create your own logic within that directory or add the directory of the raw tools to your [Octave](https://octave.org/doc/v4.0.1/Manipulating-the-Load-Path.html)/[Mablab](https://www.mathworks.com/help/matlab/ref/addpath.html) load path.

The tools require [exiftool](https://exiftool.org/). If exiftool is not in your system path then you'll want to modify the 'exiftoolPath' variable in runExiftool.m to point to where your exiftool executable lives.

## Use
See [swapRedBlueChannelsInDng.m](https://github.com/horshack-dpreview/OctaveRawTools/blob/master/swapRedBlueChannelsInDng.m) and [applyFlatFrameToDng.m](https://github.com/horshack-dpreview/OctaveRawTools/blob/master/applyFlatFrameToDng.m) for examples on how to use the tools to read, modify, and write the raw image data in DNGs. The tools only support uncompressed DNGs, which you can create using the [Adobe DNG Converter](https://helpx.adobe.com/photoshop/using/adobe-dng-converter.html). To configure the DNG converter for uncompressed, click the "Change Preferences" button, then in the Preferences dialog under "Compatibility" click the drop down and select "Custom". You'll see a "Custom DNG Compatibility" dialog - click the "Uncompressed" checkbox.

## Raw Image Stacker
Here's a getting-started guide on the raw image stacker, including information for those new to Octave. The stacker combines collections of related raw files using median or mean stacking and outputs raw file(s) with the result. This is used for a variety of purposes, including reducing noise and simulating a GND filter (similar to [Sony's Smooth Reflection App](https://www.playmemoriescameraapps.com/portal/usbdetail.php?eid=IS9104-NPIA09014_00-000011)).

### Tools Required
1. [Octave (Windows)](https://www.gnu.org/software/octave/download#ms-windows) / [Octave (Mac OSX)](https://octave-app.org/Download.html)
2. [Adobe's DNG Converter](https://helpx.adobe.com/photoshop/using/adobe-dng-converter.html)
3. [exiftool](https://exiftool.org/)

### Install Steps
1. Download the OctaveRawTools scripts (this project). You can download them directly [here](https://github.com/horshack-dpreview/OctaveRawTools/archive/refs/heads/master.zip) or, if you're familiar with git, perform a `git clone https://github.com/horshack-dpreview/OctaveRawTools` inside a command/terminal window.
2. Run Octave.
3. Set Octave's starting directory to the folder you downloaded the OctaveRawTools into. Do this by going to Preferences -> General tab, "Octave Startup" at bottom of dialog and browsing to the folder containing the OctaveRawTools scripts. Press OK. Restart Octave so it uses the new startup directory.
4. Locate the Octave "Command Window". It may be hidden in one of the tabbed windows. If you don't see it, click Window -> Show Command Window

### Usage
To run the script with default options, enter the following inside the command window then press \<enter\>:

`createStackedDngs()`

Here are the steps the script performs in its default configuration:
1. You'll be presented with a file open dialog. Navigate to the directory containing the collection of files you'd like to create stacked image(s) from, then select any file in that directory. The script will process all files in that directory which have the file extension of the file you selected. For example, if you select a file named P1040064.RW2, then all files in that directory with the "RW2" extension will be processed.
2. Script creates a temporary directory to hold the intermediate .dng files, using your system's temporary folder. For example, on Windows 10 this will be 'C:\Users\\<username\>\AppData\Local\Temp\OctaveRawTools-Temp-xxxxx', where 'xxxxx' is a randomly-generated value.
3. Invokes Adobe's DNG converter from the command line to convert all your raw files, storing them in the temporary directory created in step #2. The name of each file will be equal to the original raw file but with a .dng extension.
4. Reads the EXIF metadata from all the converted DNG files by invoking the exiftool utility.
5. Processes the EXIF to automatically find groups of related files to stack together. Files are considered part of the same stack if their EXIF "CreateDate" tag is within 2 seconds of each other.
6. When a group of related files is found (by EXIF creation date), the raw data from the DNGs is loaded into memory and the mean or median is calculated for every pixel.
7. Stores the calculated data into a new DNG. The name of the new file will be that of the first file in the stack plus `x_Stacked_Mean` or `x_Stacked_Median` appended on to it, where \<x\> is the number of files that were stacked to create the image. For example, if the first file in the stack was `DSC00524.ARW` and the group has 8 files stacked via the mean method, the output filename will be `DSC00524_8_Stacked_Mean.DNG`. The stacked image will be stored in a sub-directory named `source dir\stacked`, where `source dir` is the directory you selected in step #1.
7. The script returns to step 5 until all files are processed.

### Additional Options

**createStackedDngs** has the following optional parameters that let you customize its behavior. Each option except `sourceDir` is specified with a parameter name/value pair, separated by commas.

`sourceDir` - If you want to specify any optional parameters then the first parameter must always be the source directory. Specify '\<dialog\>' if you want to be presented with a file open dialog to set your source directory. Otherwise, specify the specific directory you'd like to use (enclosed in single quotes), such as 'c:\images\myfilestostack'. You can include an optional file mask as part of the directory - for example, 'c:\images\myfilestostack\\*.arw'. The file mask is case sensitive, so be sure to match the case of the mask to the case of your files - for example, \*.ARW vs \*.arw. If no file mask is specified then all files in the directory which have a file extension matching a known raw image file type will be processed. See [isFilenameRawImageFile.m](https://github.com/horshack-dpreview/OctaveRawTools/blob/master/isFilenameRawImageFile.m) for the list of file extensions that will be checked. You can add to this list if your camera's raw files have a different extension.

`'stackmethod', 'median | mean'` - Algorithm to use for stacking the images. The default is mean.

`'outputdir', 'path'` - Output directory to hold the stacked images. The default is in the source directory + "stacked".

`'convertraws', true | false` - By default the script will convert your raws into the necessary uncompressed DNG format the script requires. You can optionally perform this conversion yourself prior to running the script by specifying a value of false for `convertraws`. This is useful because the command-line version of Adobe's DNG converter runs noticeably slower than the GUI version, so if you have many files to stack (hundreds or thousands) then it'll be faster to convert the files using the GUI and then running the script against those DNGs. When you convert the files yourself you must configure Adobe's DNG converter to output uncompressed DNG files. This can be done by clicking the "Change Preferences" button, then in the Preferences dialog under "Compatibility" click the drop down and select "Custom". You'll see a "Custom DNG Compatibility" dialog - click the "Uncompressed" checkbox.

`'tempdir', 'path'` - By default the script will use the system's default temporary folder location to create the subfolder to hold the DNGs converted when `'convertraws'` is true. You can specify an alternate base temporary directory with this option.

`'maxtimedelta', value` - Sets the maximum EXIF CreateDate tag time delta in seconds between images to be considered part of the same sequence/stack. Default is 2.0. Specify a value of 0 to disable the time delta check - all files will be considered part of a single stack.

`'partialstacks', '<list of fractions>'` - (mean-stacking only) - Creates multiple stack renditions from each set of files, with the number of images per rendition equal to a fractional amount applied to the total image count for that collection of files. For example, on a detected stack of 256 images you can create a stack using the first 64, 128, and then all 256 images by specifying `'partialstacks', '1/4, 1/2, 1'`.  You can also use decimal notation: `'partialstacks', '.25, .5, 1'`. This feature is useful when using stacking for ND filter effects, allowing you to select from multiple renditions to select the rendition that best matches your creative vision. Be sure to include the value of '1' in the list if you want a rendition that includes all images. Note that the number of images for  any fractional value will be rounded down. For example, if you specify `'partialstacks', '1/4, 1/2, 1'` on a set with 7 images, the 1/4 value will be 1 image (1/4 * 7 = 1.75, which is rounded down to 1.0). Also note that any duplicate image counts resulting from similar fractional values will be discarded. For example, `'partialstacks', '0.25, 0.35'` on a set with 8 images will produce one stacked output with 2 images, since 0.25*8 and 0.35*8 both round down to a count of 2 images.

#### Sample Calls
`createStackedDngs('c:\pics\myraws', 'stackmethod', 'mean')`- The script will convert all raws in 'c:\pics\myraws' into a system-selected temporary directory, then stack related sets of files using the `mean` algorithm, storing the resulting stacked DNGs into `c:\pics\myraws`.

`createStackedDngs('c:\pics\mydngs', 'stackmethod', 'mean', 'convertraws', false, 'outputdir', 'c:\pics\mystackedimages')`- The script will use the raws you previously converted into uncompressed DNGs, apply the `mean` algorithm, and store the resulting stacked DNGs into `c:\pics\mystackedimages`.

### Running from the command line

You can also run the script from the command line, without invoking the Octave GUI.

#### Windows
1. The octave distribution comes with an octave.bat, which launches the command-line version of Octave. You'll want to add the path to this file to your system path by clicking the Windows Start menu and typing "env", then click "Edit the system environment variables". Click "Environment Variables", select the "Path" variable (either per-user or system-wide) and click "Edit". Click "New" and type the path to your octave.bat. For example, the path on the 64-bit installation of V6.2.0 of Octave is "c:\Program Files\GNU Octave\Octave-6.2.0\mingw64\bin\".
2. Open a command window and type the following: `octave --eval="cd <path to octave raw tools script files>; createStackedDngs()"`. For example: `octave --eval="cd 'c:\develop\octaverawtools'; createStackedDngs();"`

#### OSX
1. Create a symbolic link to octave CLI. For example, on version 6.1.0 you can use `ln -s /Applications/Octave-6.1.0.app/Contents/Resources/usr/Cellar/octave-octave-app@6.1.0/6.1.0/bin/octave-cli /usr/local/bin/octave`.
2. Sample execution, which assumes the scripts are in an OctaveRawTools subdirectory off your home directory: `octave --eval="cd '/Users/<your user name>/OctaveRawTools'; createStackedDngs('/Users/<your user name>/Documents/Images/')"`. Note that "\<dialog\>" for the source directory may not be available on some builds.
