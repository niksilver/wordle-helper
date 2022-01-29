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

-------------------------------

return {
    Words = Words
}
