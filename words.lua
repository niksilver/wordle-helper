-- Help us solve Wordle. Perhaps

dict = require('dict')

Words = {}
Words.__index = Words

-- Define a new list of possible words, given as an array.
--
function Words.new(array)
    local self = {}
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

-- Rescore the words and return: the top score, a list of the words with that score,
-- the second-top score, a list of the words with that score.
-- If there is no top or second-top scoring words that score will be zero and the
-- list will be an empty list.
--
function Words:topWords()
    self:rescore()

    local top_score = 0
    local second_score = 0
    local scores = {}

    -- Create a map from score to words with that score,
    -- and track the top and second-top scores.

    for word in pairs(self.words) do
        local word_score = self:score(word)
        local equal_words = scores[word_score] or {}

        table.insert(equal_words, word)
        scores[word_score] = equal_words

        if word_score > top_score then
            top_score, second_score = word_score, top_score
        elseif word_score == top_score then
            -- Do nothing
        elseif word_score > second_score then
            second_score = word_score
        end
    end

    -- Now we have that map, return the top and second-top scores and words.

    local top_words = {}
    if top_score > 0 then
        top_words = scores[top_score]
    end

    local second_words = {}
    if second_score > 0 then
        second_words = scores[second_score]
    end

    return top_score, top_words, second_score, second_words
end

-- Run the helper.
--
function Words.run()
    local words = Words.new(dict)
    local count = 1

    while true do
        io.write("\n" .. count .. " -------------\n")

        -- Print the recommended words from top two categories

        local top_score, top_words, second_score, second_words = words:topWords()

        if top_score > 0 then
            io.write("\n    Recommended:\n")
            for i = 1, #top_words do
                io.write("        " .. top_words[i] .. "\n")
            end
        else
            io.write("\nNo words to suggest!\n")
            return
        end

        if second_score > 0 then
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
