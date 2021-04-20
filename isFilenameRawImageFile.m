%
%% isFilenameRawImageFile
%
% Determines if the filename specified represents a raw image format by
% comparing its file extension against a list of known raw image extensions
%
% _Parameters_
% * filename  - Filename to check
%
% _Return Values_
% * isRawFile - true if the filename indicates the file is a raw image, false
%               otherwise.
%
function isRawFile = isFilenameRawImageFile(filename)

  persistent knownRawFileExtensions;

  if (isempty(knownRawFileExtensions))
    knownRawFileExtensions = {...
      '.3fr',...  % Hasselblad
      '.arw',...  % Sony
      '.cr2',...  % Canon
      '.cr3',...  % Canon
      '.dng',...  % Multiple vendors
      '.iiq',...  % Phase One
      '.nef',...  % Nikon
      '.orf',...  % Olympus
      '.pef',...  % Pentax
      '.raf',...  % Fuji
      '.rw2'...   % Panasonic
    };
  end

  [~,~,fileExt] = fileparts(filename);
  isRawFile = any(ismember(knownRawFileExtensions, lower(fileExt)));

end
