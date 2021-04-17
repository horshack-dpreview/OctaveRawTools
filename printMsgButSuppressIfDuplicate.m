
%
%% printMsgButSuppressIfDuplicate
%
% Simple mechanism to suppress repeat instances of a given message, most
% useful for warning messages
%
% _Parameters_
% * strUniqueIdentifier - A unique string identifying this message. This is different
%     than the acutal 'msg' in case there are variations of the same message and
%     caller wants all variations to be supressed
% * msg                 - Msg to print
%
% _Return Values_
% * didPrint            - true if message was printed (ie, first occurence of
%     'strUniqueIdentifier'), false if message was suppressed
%
function didPrint = printMsgButSuppressIfDuplicate(strUniqueIdentifier, msg)
  persistent supressedIdentifiers;
  if (~any(ismember(supressedIdentifiers, strUniqueIdentifier)))
    supressedIdentifiers{end+1} = strUniqueIdentifier;
    fprintf(msg);
    didPrint = true;
  else
    didPrint = false;
  end
end