# FrogAndToad

Storytelling slack bots, implemented using github.com/zvkemp/elixir-bot-server. Normally, slack bots aren't permitted to interact with each other directly, but since these are all controlled by the same Elixir VM, they *can* interact in various ways.

[![example1](https://github.com/zvkemp/frog_and_toad/blob/master/images/example_1.png)]
[![example2](https://github.com/zvkemp/frog_and_toad/blob/master/images/example_2.png)]
  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phoenix.server`

Note that Phoenix isn't actually required here; I simply added it to make heroku think it was running a web process. It will eventually be stripped out.
