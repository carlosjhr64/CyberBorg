# JS traces
# b/c xterm color escapes currently breaks coffeelint
# I put these in their own file.

# Alias debug as trace.
# It's a way to differentiate intent.
trace = (message) ->
  debug(message) if CyberBorg.TRACE

red_alert = (message) ->
  trace("\033[1;31m#{message}\033[0m")

green_alert = (message) ->
  trace("\033[1;32m#{message}\033[0m")

blue_alert = (message) ->
  trace("\033[1;34m#{message}\033[0m")
