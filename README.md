# Wordle helper

Another experiment with Lua: suggest the best words for each turn of Wordle.

Run the application. Use `g` for green, `a` for amber/yellow and `-` for nothing.
```
$ lua -e "require('words').run()"

1 -------------

    Recommended:
        arose
    Also:
        raise
        arise
        aries
        aires

    Enter your guess: arose
    Enter the clue..: -aa-g

2 -------------

    Recommended:
        rogue
        rouge
        norge
    Also:
        route
        notre
        forge

    Enter your guess: route
    Enter the clue..:
```

Run all the tests with
```
lua all-test.lua -v
```

Test the effectiveness of the strategy like this, to run it 100 times
and plot the results.
```
lua -e "require('evaluator').runAndPlot(100)"
```
