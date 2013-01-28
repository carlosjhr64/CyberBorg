# JS traces
# b/c xterm color escapes currently breaks coffeelint
# I put these in their own file.
#
# I do a lot of double checking of trace.on.
# But this extra work only occurs while tracing.
# The point is to not do unecessary work while not tracing.
class Trace
  constructor: () ->
    @on = (selectedPlayer is me)

  out: (message) -> debug(message) if @on

  # red alerts are a bit different.
  # They're meant to let me know of a potential bug.
  # It'll relay the message if being run in test mode,
  # regardless of the value of trace.
  red: (message) ->
    previous_state = @on
    if @on or (selectedPlayer is me)
      @on = true # regarless of previous state.
      @out "\u001b[1;31m#{message}\u001b[0m"
    @on = previous_state

  green: (message) ->
    @out "\u001b[1;32m#{message}\u001b[0m" if @on

  blue: (message) ->
    @out "\u001b[1;34m#{message}\u001b[0m" if @on
