-- Help us solve Wordle. Perhaps

local dict = require('dict')

local Words = {}
Words.__index = Words

-- Define a new list of possible words, given as an `array`.
-- The default scoring function is `highestScoringWords()`, but this can
-- be changed by setting the optional `scoring_fn`.
--
function Words.new(array, scoring_fn)
    local self = {}
    self.bestWords = scoring_fn or Words.highestScoringWords

    setmetatable(self, Words)

    -- words is just a mapping from word to true

    local words = {}
    for _, word in pairs(array) do
        words[word] = true
    end
    self.words = words

    -- freqs is a mapping from letter to its frequency

    self.freqs = {}
    return self
end

-- Does the list of words contain the given word?
--
function Words:contains(word)
    return (not(not self.words[word]))
end

-- Manually rescore all the words. Calculates frequency of each letter
-- and the total score of each word (ie the sum of its lstter frequencies).
-- Note that a letter will only count once in a word.
--
function Words:rescore()
    local freqs = {}

    for word, _ in pairs(self.words) do

        -- First collect the letters - once each
        
        local letters = {}
        for i = 1, #word do
            local letter = word:sub(i, i)
            letters[letter] = true
        end

        -- Now increment the frequency scores

        for letter, _ in pairs(letters) do
            local freq = self.freqs[letter]
            if freq == nil then
                self.freqs[letter] = 1
            else
                self.freqs[letter] = freq + 1
            end
        end
    end
end

-- What is the frequency of a given letter?
--
function Words.freq(self, letter)
    return self.freqs[letter] or 0
end

-- Find the score of a given word. Each letter only counts once.
--
function Words:score(word)
    -- First collect the letters

    local letters = {}
    for i = 1, #word do
        letters[word:sub(i, i)] = true
    end

    -- Now add up the score

    local score = 0

    for letter, _ in pairs(letters) do
        score = score + self.freqs[letter]
    end

    return score
end

-- Should we keep `subject` given that word `guess` results in `clue`?
-- The `clue` is a string of five characters:
-- `-` means the letter doesn't appear;
-- `a` means the letter appears, but not here (amber);
-- `g` means the letter appears here (green).
-- This is a class method, not an instance method.
--
function Words.keepGiven(subject, guess, clue)
    for i = 1, #clue do
        local light = clue:sub(i, i)
        local letter = guess:sub(i, i)

        -- If we have a green light, we'll reject the word if
        -- corresponding letters in the subject and the guess
        -- are different.
        if light == "g" then
            if subject:sub(i, i) ~= letter then
                return false
            end
        end

        -- If we have an amber light we'll reject the word if
        -- the corresponding letters match, or if there's no
        -- such letter elsewhere in the subject.
        if light == "a" then
            if subject:sub(i, i) == letter then
                return false
            else
                local rest = subject:sub(1, i-1) .. subject:sub(i+1, #subject)
                if rest:find(letter) == nil then
                    return false
                end
            end
        end

        -- If we have a blank light we'll reject the word if that
        -- letter appears somewhere in the subject.
        if light == "-" then
            if subject:find(letter) ~= nil then
                return false
            end
        end
    end

    return true
end

-- Given a `guess` and a `clue` eliminate all impossible words.
-- Returns a new instance of the class (with the reduced word list).
--
function Words:eliminateGiven(guess, clue)
    local list = {}
    for subject, _ in pairs(self.words) do
        if Words.keepGiven(subject, guess, clue) then
            table.insert(list, subject)
        end
    end

    return Words.new(list)
end

-- Rescore the words and return: a list of the words with the best score,
-- a list of the words with the second-best score.
-- If there is no best or second-best scoring words the relevant lists
-- will be empty.
--
function Words:bestWords()
    return self:highestScoringWords()
end

-- Rescore the words and return: a list of the words with the highest score,
-- and a list of the words with the second-highest score.
-- If there is no highest or second-highest scoring words the relevant lists
-- will be empty.
--
function Words:highestScoringWords()
    self:rescore()

    local highest_score = 0
    local second_score = 0
    local scores = {}

    -- Create a map from score to words with that score,
    -- and track the highest and second-highest scores.

    for word in pairs(self.words) do
        local word_score = self:score(word)
        local equal_words = scores[word_score] or {}

        table.insert(equal_words, word)
        scores[word_score] = equal_words

        if word_score > highest_score then
            highest_score, second_score = word_score, highest_score
        elseif word_score == highest_score then
            -- Do nothing
        elseif word_score > second_score then
            second_score = word_score
        end
    end

    -- Now we have that map, return the highest and second-highest scores and words.

    local highest_words = {}
    if highest_score > 0 then
        highest_words = scores[highest_score]
    end

    local second_words = {}
    if second_score > 0 then
        second_words = scores[second_score]
    end

    return highest_words, second_words
end

-- Like `highestScoringWords`, but selects the lowest scoring and second-lowest
-- scoring words.
--
function Words:lowestScoringWords()
    self:rescore()

    local lowest_score = nil
    local second_score = nil
    local scores = {}

    -- Create a map from score to words with that score,
    -- and track the lowest and second-lowest scores.

    for word in pairs(self.words) do
        local word_score = self:score(word)
        local equal_words = scores[word_score] or {}

        table.insert(equal_words, word)
        scores[word_score] = equal_words

        if lowest_score == nil or word_score < lowest_score then
            lowest_score, second_score = word_score, lowest_score
        elseif word_score == lowest_score then
            -- Do nothing
        elseif second_score == nil or word_score < second_score then
            second_score = word_score
        end
    end

    -- Now we have that map, return the lowest and second-lowest scores and words.

    local lowest_words = {}
    if lowest_score ~= nil then
        lowest_words = scores[lowest_score]
    end

    local second_words = {}
    if second_score ~= nil then
        second_words = scores[second_score]
    end

    return lowest_words, second_words
end

-- A scoring function to select the best and second best words randomly -
-- three of each
--
function Words:randomWords()
    -- We don't want to select words twice, so in order to eliminate selected
    -- words from our list we need to start with a copy of our word list and
    -- use that to choose and eliminate from.

    local words = {}
    for word, _ in pairs(self.words) do
        table.insert(words, word)
    end

    -- Select up to 3 words for the first list to return, and up to 3 words
    -- for the second list.

    local first_list = {}

    for i = 1, math.min(#words, 3) do
        local index = math.random(#words)
        if #words == 1 then
            index = 1
        end

        table.insert(first_list, words[index])
        table.remove(words, index)
    end

    local second_list = {}

    for i = 1, math.min(#words, 3) do
        local index = math.random(#words)
        if #words == 1 then
            index = 1
        end

        table.insert(second_list, words[index])
        table.remove(words, index)
    end

    return first_list, second_list
end

-- Pick the best word, or nil if there is none.
--
function Words:bestWord()
    local best_words, second_words = self:bestWords()

    if #best_words == nil then
        return nil
    else
        return best_words[1]
    end
end

-- Run the helper. The default scoring function can be changed by setting the
-- optional `scoring_fn`.
--
function Words.run(scoring_fn)
    local words = Words.new(dict, scoring_fn)
    local count = 1

    while true do
        io.write("\n" .. count .. " -------------\n")

        -- Print the recommended words from best two categories

        local best_words, second_words = words:bestWords()

        if #best_words > 0 then
            io.write("\n    Recommended:\n")
            for i = 1, #best_words do
                io.write("        " .. best_words[i] .. "\n")
            end
        else
            io.write("\nNo words to suggest!\n")
            return
        end

        if #second_words > 0 then
            io.write("    Also:\n")
            for i = 1, #second_words do
                io.write("        " .. second_words[i] .. "\n")
            end
        end

        -- Get feedback and recalculate options

        io.write("\n")
        io.write("    Enter your guess: ")
        local guess = io.read("*l")
        io.write("    Enter the clue..: ")
        local clue = io.read("*l")

        words = words:eliminateGiven(guess, clue)

        count = count + 1
    end
end

-------------------------------

return Words
