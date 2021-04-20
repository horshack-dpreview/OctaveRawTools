%
%% OS class
%
% Class for encapsulating differences between operating systems
%
classdef OS < handle;

  methods
    function this = OS(this)
    end
  end

  methods (Static, Access = public)

    function init()
      global OS_;
      OS_ = Platform();
    end

    %
    % returns the currently logged in user's home directory
    %
    function dir = getHomeDir()
      if (ispc)
        dir = getenv('USERPROFILE');
      else
        dir = getenv('HOME');
      end
    end

  end

end % classdef Platform
