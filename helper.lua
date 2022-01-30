-- Help us solve Wordle. Perhaps

Words = {}
Words.__index = Words

-- Define a new list of words, given as an array.
--
function Words.new(array)
    local self = {}
    setmetatable(self, Words)

    -- words is a mapping from word to... zero?!

    local words = {}
    for _, word in pairs(array) do
        words[word] = 0
    end
    self.words = words

    -- freqs is a mapping from letter to its frequency

    self.freqs = {}
    return self
end

-- Does the list of words contain the given word?
--
function Words.contains(self, word)
    return (not(not self.words[word]))
end

-- Manually rescore all the words. Calculates frequency of each letter
-- and the total score of each word (ie the sum of its lstter frequencies).
-- Note that a letter will only count once in a word.
--
function Words.rescore(self)
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
function Words.score(self, word)
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
function Words.eliminateGiven(self, guess, clue)
    local list = {}
    for subject, _ in pairs(self.words) do
        if Words.keepGiven(subject, guess, clue) then
            table.insert(list, subject)
        end
    end

    return Words.new(list)
end

-- Rescore the words and find the top scoring ones. Returns a list of the words
-- and the score.
--
function Words.topWords(self)
    self:rescore()

    local score = 0
    local words = {}

    for word in pairs(self.words) do
        local word_score = self:score(word)
        if word_score > score then
            score = word_score
            words = { word }
        elseif word_score == score then
            table.insert(words, word)
        end
    end

    return words, score
end

-------------------------------

return {
    Words = Words
}
