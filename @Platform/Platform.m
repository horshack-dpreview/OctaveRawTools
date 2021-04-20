%
%% Platform class
%
% Singleton class for encapsulating differences between Octave and Matlab
%
classdef Platform < handle;

  properties (Access = public)
    fIsOctave;
  end

  methods
    function this = Platform(this)
      this.fIsOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0; % https://stackoverflow.com/a/2246651/5319360
    end
  end

  methods (Static, Access = public)

    function init()
      global Platform_;
      Platform_ = Platform();
    end

    function is = isOctave()
      global Platform_;
      is = Platform_.fIsOctave;
    end

    %
    % returns the current epoch time
    %
    function et = epochTime()
      global Platform_;
      if (Platform_.fIsOctave)
        et = time();
      else
        et = posixtime(datetime('now'));
      end
    end

  end

end % classdef Platform
