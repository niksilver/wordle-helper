# Wordle helper

Another experiment with Lua: suggest the best words for each turn of Wordle.

Run the application. Use `g` for green, `a` for amber/yellow and `-` for nothing.
```
% lua -e "require('words').run()"
1 -------------

    1 best option(s):
    arose

    Enter your guess: float
    Enter the clue..: -ag--

2 -------------

    2 best option(s):
    scowl
    spoil

    Enter your guess:
```

Run the tests with
```lua
lua words-tests.lua -v
```
