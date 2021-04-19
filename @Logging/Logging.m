%
%% Logging class
%
% Single-instance class for logging messages to the console, with logging level
% threshold for controlling which class of messages are actually printed
%
classdef Logging < handle;

  properties (Constant)
    LOGGING_LEVEL_SILENT    = int32(0);
    LOGGING_LEVEL_ERROR     = int32(1);
    LOGGING_LEVEL_WARNING   = int32(2);
    LOGGING_LEVEL_INFO      = int32(3);
    LOGGING_LEVEL_VERBOSE   = int32(4);
    LOGGING_LEVEL_DEBUG     = int32(5);

    LOGGING_LEVEL_DEFAULT   = int32(3); % can't reference Logging.LOGGING_LEVEL_INFO due to bug (https://savannah.gnu.org/bugs/?57557)
  end

  %properties (Access = private)
  properties (Access = public)
    loggingLevel;
  end

  methods

    function this = Logging(this)
      this.loggingLevel = Logging.LOGGING_LEVEL_DEFAULT;
    end

  end

  methods (Static, Access = private)

    function log(loggingLevel, fmtStr, varargin_)
      global L;
      if (loggingLevel <= L.loggingLevel)
        fprintf(fmtStr, varargin_{:});
      end
    end

  end

  methods (Static, Access = public)

    function create()
      global L;
      L = Logging();
    end

    function setLoggingLevel(loggingLevel)
      global L;
      L.loggingLevel = loggingLevel;
    end

    function isLogging = isLevelLogged(loggingLevel)
      global L;
      isLogging = (L.loggingLevel >= loggingLevel);
    end

    function error(fmtStr, varargin)
      Logging.log(Logging.LOGGING_LEVEL_ERROR, ['Error: ' fmtStr], varargin);
    end

    function warning(fmtStr, varargin)
      Logging.log(Logging.LOGGING_LEVEL_WARNING, ['Warning: ' fmtStr], varargin);
    end

    function info(fmtStr, varargin)
      Logging.log(Logging.LOGGING_LEVEL_INFO, fmtStr, varargin);
    end

    function verbose(fmtStr, varargin)
      Logging.log(Logging.LOGGING_LEVEL_VERBOSE, fmtStr, varargin);
    end

    function debug(fmtStr, varargin)
      Logging.log(Logging.LOGGING_LEVEL_DEBUG, fmtStr, varargin);
    end

  end

end % classdef Logging
