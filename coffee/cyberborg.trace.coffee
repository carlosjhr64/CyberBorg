# JS traces
# b/c xterm color escapes currently breaks coffeelint
# I put these in their own file.

# Alias debug as trace
# It's a way to differentiat intent
trace = (message) ->
  debug(message) if CyberBorg.TRACE
