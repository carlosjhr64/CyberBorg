# JS traces
# b/c xterm color escapes currently breaks coffeelint
# I put these in their own file.
#
# I do a lot of double checking of TRACE.
# But this extra work only occurs while tracing.
# The point is to not do unecessary work while not tracing.
#
# Alias debug as trace.
# It's a way to differentiate intent.
trace = (message) ->
  debug(message) if CyberBorg.TRACE

# red alerts are a bit different.
# They're meant to let me know of a potential bug.
# It'll relay the message if being run in test mode,
# regardless of the value of TRACE.
red_alert = (message) ->
  previous_state = CyberBorg.TRACE
  if CyberBorg.TRACE or (selectedPlayer is me)
    CyberBorg.TRACE = true # regarless of previous state.
    trace("\033[1;31m#{message}\033[0m")
  CyberBorg.TRACE = previous_state

green_alert = (message) ->
  trace("\033[1;32m#{message}\033[0m") if CyberBorg.TRACE

blue_alert = (message) ->
  trace("\033[1;34m#{message}\033[0m") if CyberBorg.TRACE
