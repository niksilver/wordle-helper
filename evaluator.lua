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

-- Run the evaluator `runs` many times and return a map of goes.
--
function Evaluator.runMany(runs)
    math.randomseed(os.time())

    local stats = {}

    for i = 1, runs do
        local goes = Evaluator.runOnce()
        if stats[goes] == nil then
            stats[goes] = 1
        else
            stats[goes] = stats[goes] + 1
        end
    end

    return stats
end

-- Run the evaluator `runs` many times and plot the results
--
function Evaluator.runAndPlot(runs)
    local stats = Evaluator.runMany(runs)

    -- Calculate the data for the bar chart

    local max_goes = 0
    local max_bar = 0
    local total_goes = 0

    for goes, count in pairs(stats) do
        max_goes = math.max(goes, max_goes)
        max_bar = math.max(count, max_bar)
        total_goes = total_goes + goes * count
    end

    -- Output the bar chart, scaling it to 40 characters

    local scale = 40 / max_bar

    for i = 1, max_goes do
        stats[i] = stats[i] or 0
        local num = string.format('%4d', i)
        local bar_size = math.ceil(stats[i] * scale)
        local bar = string.rep("=", bar_size)
        io.write(num .. " " .. bar .. "\n")
    end

    local average = total_goes / runs
    io.write("\nAverage " .. average .. "\n")

end

-------------------------------

return Evaluator
