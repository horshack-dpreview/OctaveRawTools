%
%% Logging class
%
% Singleton class for logging messages to the console, with logging level
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

  properties (Access = private)
    loggingLevel;
  end

  methods

    function this = Logging(this)
      this.loggingLevel = Logging.LOGGING_LEVEL_DEFAULT;
    end

  end

  methods (Static, Access = private)

    function log(loggingLevel, fmtStr, varargin_)
      global Logging_;
      if (loggingLevel <= Logging_.loggingLevel)
        fprintf(fmtStr, varargin_{:});
      end
    end

  end

  methods (Static, Access = public)

    function inst = init()
      global Logging_;
      Logging_ = Logging();
      inst = Logging_;
    end

    function setLoggingLevel(loggingLevel)
      global Logging_;
      Logging_.loggingLevel = loggingLevel;
    end

    function isLogging = isLevelLogged(loggingLevel)
      global Logging_;
      isLogging = (Logging_.loggingLevel >= loggingLevel);
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
