-- Help us solve Wordle. Perhaps

Words = {}
Words.__index = Words

-- Define a new list of words, given as an array.
--
function Words.new(array)
    local self = {}
    setmetatable(self, Words)

    local words = {}
    for _, word in pairs(array) do
        words[word] = 0
    end
    self.words = words
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
--
function Words.rescore(self)
    local freqs = {}

    for word, _ in pairs(self.words) do
        for i = 1, #word do
            local letter = word:sub(i, i)
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

-- Find the score of a given word.
--
function Words.score(self, word)
    local score = 0

    for i = 1, #word do
        score = score + self.freqs[word:sub(i, i)]
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

-------------------------------

return {
    Words = Words
}
