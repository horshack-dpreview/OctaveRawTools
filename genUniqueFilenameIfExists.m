
%
%% genUniqueFilenameIfExists
%
% Checks if the specified file exists. If it does, generates a new filename
% based on the root of the original filename with -1 appended to the name.
% If the -1 already exists then it uses -2, -3, etc...
%
% _Parameters_
% * filename - Full path to filename
%
% _Return Values_
% * newFilename - New filename to use. If 'filename' doesn't exist then
%               - 'newFilename' will be the same as 'filename'.
%
function newFilename = genUniqueFilenameIfExists(filename)

  newFilename = filename;

  while isfile(newFilename)

    [directory, root, ext] = fileparts(newFilename);

    suffixNumber = regexp(root, '.*?-([0-9]+)', 'tokens');
    if (numel(suffixNumber) == 0)
      % check if the filename + "-1" exists
      root = [root '-1'];
    else
      % check if the filename + "-xxx" exists, where xxx is +1 prev val check
      root = regexprep(root, '-[0-9]+$', ['-' num2str(str2num(suffixNumber{1}{1})+1)]);
    end

    newFilename = fullfile(directory, [root ext]);

end
