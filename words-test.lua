-- Tests for the wordle helper

lu = require('luaunit')
Words = require('words')

-------------------------------------------------------

TestWords = {}

function TestWords:testNew()
    local words = Words.new({ "alice", "bob" })
    lu.assertEquals( words:contains("alice"), true )
    lu.assertEquals( words:contains("bob"), true )
    lu.assertEquals( words:contains("chloe"), false )
end

function TestWords:testRescore()
    local words = Words.new({ "alice", "lucky", "ally" })
    words:rescore()

    lu.assertEquals( words:freq('a'), 2 )
    lu.assertEquals( words:freq('c'), 2 )
    lu.assertEquals( words:freq('d'), 0 )
    lu.assertEquals( words:freq('y'), 2 )

    -- But a letter shouldn't count twice if it's repeated
    lu.assertEquals( words:freq('l'), 3 )

    lu.assertEquals( words:score("alice"), 9)
    lu.assertEquals( words:score("ali"), 6)
    lu.assertEquals( words:score("luc"), 6)

    -- A word shouldn't score each letter only once
    lu.assertEquals( words:score("ally"), 7)
end

function TestWords:testKeepGiven()
    local words = Words.new({})

    -- Given a first green - yes and no
    lu.assertEquals( words.keepGiven("house", "hilly", "g----"), true)
    lu.assertEquals( words.keepGiven("rouse", "hilly", "g----"), false)

    -- Given a middle green - yes and no
    lu.assertEquals( words.keepGiven("mince", "hilly", "-g---"), true)
    lu.assertEquals( words.keepGiven("rouse", "hilly", "-g---"), false)

    -- Given a last green - yes and no
    lu.assertEquals( words.keepGiven("mancy", "hilly", "----g"), true)
    lu.assertEquals( words.keepGiven("rouse", "hilly", "----g"), false)

    -- Given a first amber - yes and no
    lu.assertEquals( words.keepGiven("catch", "hilly", "a----"), true)
    lu.assertEquals( words.keepGiven("hatch", "hilly", "a----"), false)
    lu.assertEquals( words.keepGiven("abcde", "hilly", "a----"), false)

    -- Given a middle amber - yes and no
    lu.assertEquals( words.keepGiven("brink", "hilly", "-a---"), true)
    lu.assertEquals( words.keepGiven("lilly", "hilly", "-a---"), false)
    lu.assertEquals( words.keepGiven("lolly", "hilly", "-a---"), false)

    -- Given a last amber - yes and no
    lu.assertEquals( words.keepGiven("yacxt", "hilly", "----a"), true)
    lu.assertEquals( words.keepGiven("lilee", "hilly", "----a"), false)

    -- Given no match at the start - yes and no
    lu.assertEquals( words.keepGiven("youex", "house", "-gg-a"), true)
    lu.assertEquals( words.keepGiven("kwxzh", "hwxyz", "-gg-a"), false)

    -- Given no match in the middle - yes and no
    lu.assertEquals( words.keepGiven("baxed", "abcde", "aa-aa"), true)
    lu.assertEquals( words.keepGiven("badec", "abcde", "aa-aa"), false)

    -- Given no match at the end - yes and no
    lu.assertEquals( words.keepGiven("badcx", "abcde", "aaaa-"), true)
    lu.assertEquals( words.keepGiven("badec", "abcde", "aaaa-"), false)

    -- Given one amber, one green
    lu.assertEquals( words.keepGiven("xyzdc", "abcde", "--ag-"), true)

    -- Given a double letter, of which one is right
    lu.assertEquals( words.keepGiven("peeps", "really", "-g---"), true)

    -- This is a double letter, but should fail
    lu.assertEquals( words.keepGiven("peeps", "really", "-a---"), false)
end

function TestWords:testEliminateGiven()
    local words1 = Words.new({
        "house",
        "lilly",
        "round",
        "group",
        "rapid",
        "spurn"
    })

    -- Let's pretend the word is........ "spurn"
    local words2 = words1:eliminateGiven("truly", "-ag--")

    lu.assertEquals( words2:contains("house"), false )
    lu.assertEquals( words2:contains("lilly"), false )
    lu.assertEquals( words2:contains("round"), true )
    lu.assertEquals( words2:contains("group"), false )
    lu.assertEquals( words2:contains("rapid"), false )
    lu.assertEquals( words2:contains("spurn"), true )
end

function TestWords:testTopWords()
    local words = Words.new({
        "house",
        "lilly",
        "round",
        "group",
        "rapid",
        "spurn"
    })

    -- Frequencies are:
    -- h: 1
    -- o: 3
    -- u: 4
    -- s: 2
    -- e: 1
    -- l: 1
    -- i: 2
    -- y: 1
    -- r: 4
    -- n: 2
    -- d: 2
    -- g: 1
    -- p: 3
    -- a: 1
    --
    -- Therefore scores are:
    -- house -> 1 3 4 2 1 -> 11
    -- lilly -> 1 2 0 0 1 -> 4
    -- round -> 4 3 4 2 2 -> 15
    -- group -> 1 4 3 4 3 -> 15
    -- rapid -> 4 1 3 2 2 -> 12
    -- spurn -> 2 3 4 4 2 -> 15

    local top_words, second_words = words:topWords()

    lu.assertItemsEquals(top_words, { "group", "round", "spurn" })
    lu.assertEquals(words:score("group"), 15)
    lu.assertItemsEquals(second_words, { "rapid" })
    lu.assertEquals(words:score("rapid"), 12)
end

function TestWords:testTopWordsWithNoSecondScore()
    local words = Words.new({
        "house",
    })

    local top_words, second_words = words:topWords()

    lu.assertItemsEquals(top_words, { "house" })
    lu.assertEquals(words:score("house"), 5)
    lu.assertItemsEquals(second_words, {})
end

function TestWords:testTopWordsWithNoTopScore()
    local words = Words.new({
    })

    local top_words, second_words = words:topWords()

    lu.assertItemsEquals(top_words, {})
    lu.assertItemsEquals(second_words, {})
end


-------------------------------------------------------

return lu.LuaUnit.run()
