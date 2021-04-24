
%
%% processNamedVariableArgs
%
% Parses a series of argument name / value pairs, based on a specified set
% of valid arguments. This is used by functions which accept variable arguments,
% each of which is specified by the user in argument pairs, with the first
% argument being the name and the second being the value. For example:
%
% myFunc(regularArg_1, regularArg_2, varargin)
%
% Where 'varargin' are the argument pairs (typically optional) for additional
% arguments to myFunc. For example:
%
% myFunc(10, 20, 'operation', 'add')
%
% The caller specifies the list of valid arguments in 'argStruct', where each
% index has the following fields:
%
% .name         - Argument name
% .class        - Variable class (ie, type). Supported classes:
%                   'char'    - String value returned
%                   'logical' - Logical value returned (ie, converts "true" to true
%                   <any>     - If none of the above, must be scalar number class,
%                               such as 'double', 'uint32', etc...
% .validValues  - [Optional]  - Cell array of valid values [post-class conversion]
% .defaultValue - [Optional]  - Default value. Set to empty string for none
% .required     - [Optional]  - True if argument must be specified in varargin_.
%                               If argument is not found in varargin_ then error
%                               message will be printed and success will be false.
% Example:
%
% function myFunc(regularArg_1, regularArg_2, varargin)
%   argStruct = struct;
%   argStruct(1).name = 'operation';
%   argStruct(1).class = 'char';
%   argStruct(1).defaultValue = 'subtract';
%   argStruct(1).required = false;
%
%   [success, argValues] = processNamedVariableArgs(varargin, argStruct);
%
% Where the caller to myFunc was: myFunc(10, 20, 'operation', add')
%
% _Parameters_
% * varargin_   - varargin the caller received
% * argStruct   - Structure with one or more entries describing the valid arguments
%
% _Return Values_
% * success     - true if successful, false if not.
% * argValues   - Structure where the field names are the argument names
%                 and the values are the argument values. Only argument names
%                 found in varargin_ will be included in argValues. Also included
%                 will be any argStruct elements with default values
%
function [success, argValues] = processNamedVariableArgs(varargin_, argStruct)

  function index = getArgStructIndexForArgName(argName)
    index = -1;
    for i = 1:numel(argStruct)
      if (strcmpi(argStruct(i).name, argName))
        index = i;
        break;
      end
    end
  end

  argValues = struct;
  fProcessedArgStructIndex = zeros(1, numel(argStruct));

  success = false; % assume error

  % create argValues for args that have default values
  for i=1:numel(argStruct)
    if (isfield(argStruct(i), 'defaultValue') && ~isempty(argStruct(i).defaultValue))
      argValues.(argStruct(i).name) = argStruct(i).defaultValue;
    end
  end

  %
  % process the arguments passed by the user
  %
  numArgs = numel(varargin_);
  nextArgIndex = 1;
  while (nextArgIndex <= numArgs)

    % get next argument/value pair
    argName = varargin_{nextArgIndex};
    asi = getArgStructIndexForArgName(argName);
    if (asi == -1)
      fprintf('Unrecognized arg "%s"\n', argName);
      return;
    end
    if (nextArgIndex == numArgs) % make sure arg value is available too
      fprintf('Error: No value specified for arg "%s"\n', argName);
      return;
    end
    argValue = varargin_{nextArgIndex+1};

    if (fProcessedArgStructIndex(asi))
      fprintf('Warning: arg "%s" specified more than once. Using newestvalue\n', argName);
    end

    % procss the argument value
    switch (argStruct(asi).class)
    case 'char'
      % nothing to do
    case 'string'
      % nothing to do
    case 'logical'
      if (strcmp(class(argValue), 'logical'))
        % nothing to do - value is already in logical type form
        1;
      elseif (strcmp(class(argValue), 'char'))
        if (strcmpi(argValue, 'true') || strcmpi(argValue, '1'))
          argValue = true;
        elseif (strcmpi(argValue, 'false') || strcmpi(argValue, '0'))
          argValue = false;
        else
          fprintf('Error: Expected logical value for arg "%s" must be "true" or "false"\n', argName);
          return;
        end
      else
        % arg assumed to be scalar number (ex: 0, 1, ..). simply cast to logical
        argValue = cast(argValue, 'logical');
      end
    otherwise
      % arg specified assumed to be a scalar number type (or logical). ex: 'double', 'uint32', etc...
      if (strcmp(class(argValue), 'char'))
        argValue = str2num(argValue);
      end
      argValue = cast(argValue, argStruct(asi).class);
    end


    %
    % if a set of valid values was specified for this arg, make sure the value
    % specified for the argument is one of them
    %
    if (isfield(argStruct(i), 'validValues') && ~isempty(argStruct(i).validValues))
      numValidValues = numel(argStruct(asi).validValues);
      fFoundValidValue = false;
      fCompareAsChar = strcmp(class(argValue), "char");
      for i=1:numValidValues
        if (fCompareAsChar)
          if (strcmpi(argValue, argStruct(asi).validValues{i}))
            argValue = argStruct(asi).validValues{i}; % make sure matches case of validValue specified
            fFoundValidValue = true;
            break;
          end
        else % assume scalar type
          if (argValue == argStruct(asi).validValues{i})
            fFoundValidValue = true;
            break;
          end
        end
      end
      if (~fFoundValidValue)
        fprintf('Error: arg "%s" must be one of the following values:\n', argName);
        disp(argStruct(asi).validValues);
        return;
      end
    end

    % store value in argValues map
    argValues.(argStruct(asi).name) = argValue;
    fProcessedArgStructIndex(asi) = true;

    nextArgIndex = nextArgIndex+2;

  end

  %
  % make sure all required arguments were passed
  %
  for i=1:numel(argStruct)
    if (isfield(argStruct(i), 'required') && ~isempty(argStruct(i).required) && argStruct(i).required && fProcessedArgStructIndex(i)==false)
      fprintf('Error: arg "%s" is mandatory but was not provided\n', argStruct(i).name);
      return;
    end
  end

  success = true;
end

