# JS traces
# b/c xterm color escapes currently breaks coffeelint
# I put these in their own file.
#
# I do a lot of double checking of trace.on.
# But this extra work only occurs while tracing.
# The point is to not do unecessary work while not tracing.
class Trace
  @on = (selectedPlayer is me)
  @out = (message) -> debug(message) if Trace.on

  # red alerts are a bit different.
  # They're meant to let me know of a potential bug.
  # It'll relay the message if being run in test mode,
  # regardless of the value of trace.
  @red = (message) ->
    if Trace.on or (selectedPlayer is me)
      previous_state = Trace.on
      Trace.on = true # regarless of previous state.
      @out "\u001b[1;31m#{message}\u001b[0m"
      Trace.on = previous_state
  @debug = @red # Alias

  @green = (message) ->
    @out "\u001b[1;32m#{message}\u001b[0m" if Trace.on

  @blue = (message) ->
    @out "\u001b[1;34m#{message}\u001b[0m" if Trace.on

  @error = (error, title='ERROR!') ->
    if Trace.on or (selectedPlayer is me)
      previous_state = Trace.on
      Trace.on = true # regarless of previous state.
      @out "\u001b[1;31m#{title}\u001b[0m"
      @out "\u001b[1;31m#{error.lineNumber}: #{error.message}\u001b[0m"
      Trace.on = previous_state
