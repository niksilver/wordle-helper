-- Evaluate our guessing strategy.

local Words = require('words')
local dict = require('dict')

Evaluator = {}
Evaluator.__index = Evaluator

-------------------------------

-- Given the `answer` and the `guess` return the clue.
--
function Evaluator.clue(answer, guess)
    local clue = ''

    for i = 1, #guess do
        local guess_letter = string.sub(guess, i, i)
        local answer_letter = string.sub(answer, i, i)
        local answer_pos = string.find(answer, guess_letter)
        local chr = '-'

        if guess_letter == answer_letter then
            chr = 'g'
        elseif answer_pos ~= nil then
            chr = 'a'
        end

        clue = clue .. chr
    end

    return clue
end

-- Run the evaluator once against a random work, and return the number of tries.
--
function Evaluator.runOnce()
    local words = Words.new(dict)
    local answer = dict[math.random(#dict)]
    local goes = 0
    local clue = "-----"

    while clue ~= "ggggg" do
        local guess = words:bestWord()
        clue = Evaluator.clue(answer, guess)
        goes = goes + 1
        if clue ~= "ggggg" then
            words = words:eliminateGiven(guess, clue)
        end
    end

    return goes
end

-------------------------------

return Evaluator
