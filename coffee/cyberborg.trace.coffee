# JS traces
# b/c xterm color escapes currently breaks coffeelint
# I put these in their own file.
#
# I do a lot of double checking of cyberBorg.trace.
# But this extra work only occurs while tracing.
# The point is to not do unecessary work while not tracing.
#
# trace insted of debug is a way to differentiate intent.
trace = (message) ->
  debug(message) if cyberBorg.trace

# red alerts are a bit different.
# They're meant to let me know of a potential bug.
# It'll relay the message if being run in test mode,
# regardless of the value of trace.
red_alert = (message) ->
  previous_state = cyberBorg.trace
  if cyberBorg.trace or (selectedPlayer is me)
    cyberBorg.trace = true # regarless of previous state.
    trace "\u001b[1;31m#{message}\u001b[0m"
  cyberBorg.trace = previous_state

green_alert = (message) ->
  trace "\u001b[1;32m#{message}\u001b[0m" if cyberBorg.trace

blue_alert = (message) ->
  trace "\u001b[1;34m#{message}\u001b[0m" if cyberBorg.trace
