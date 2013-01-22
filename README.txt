CyberBorg
=========

Warzone 2100 AI.

WZ2100 people at
  http://wz2100.net/
have added a javascript API.
  https://warzone.atlassian.net/wiki/display/jsapi/Javascript+API

I hate JavaScript.  :))
But I'm developing my own AI assist in CoffeeScript.
Looks promising.

Right now I'm actively developing...
It'll play a no base T1 game up to dual machine guns...

I'm developing in the 8 player map, Concrete,
with low power level.

In the very last line of
   ./data/mp/multiplay/skirmish/rules.js
I include
   'multiplay/skirmish/cyberborg-devel.js'
That way I can test changes to the AI against its previous version
without having to go to debug mode.
