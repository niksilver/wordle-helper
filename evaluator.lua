-- Evaluate our guessing strategy.

Words = require('words')

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

-------------------------------

return Evaluator
