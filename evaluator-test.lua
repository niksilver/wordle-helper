-- Tests for the wordle evaluator

lu = require('luaunit')
Evaluator = require('evaluator')

-------------------------------------------------------

TestEvaluator = {}

function TestEvaluator:testClue()

    -- All blanks

    lu.assertEquals( Evaluator.clue('house', 'ambit'), '-----')

    -- One amber

    lu.assertEquals( Evaluator.clue('house', 'stall'), 'a----')

    -- More than one amber

    lu.assertEquals( Evaluator.clue('house', 'stoll'), 'a-a--')

    -- One green

    lu.assertEquals( Evaluator.clue('house', 'cluck'), '--g--')

    -- Two greens

    lu.assertEquals( Evaluator.clue('house', 'mount'), '-gg--')

    -- Mix of green and ambers

    lu.assertEquals( Evaluator.clue('house', 'plush'), '--gga')

    -- A green that hides an amber

    lu.assertEquals( Evaluator.clue('holly', 'ablde'), '--g--')

    -- A double letter in the guess that's only used once

    lu.assertEquals( Evaluator.clue('milds', 'holly'), '--ga-')
end

-------------------------------------------------------

os.exit( lu.LuaUnit.run() )
