-- Help us solve Wordle. Perhaps

Words = {}
Words.__index = Words

function Words.new(array)
    local self = {}
    setmetatable(self, Words)

    local words = {}
    for _, word in pairs(array) do
        words[word] = 0
    end
    self.words = words
    return self
end

-- Does the list of words contain the given word?
--
function Words.contains(self, word)
    if self.words[word] == nil then
        return false
    else
        return true
    end
end

-------------------------------

return {
    Words = Words
}
