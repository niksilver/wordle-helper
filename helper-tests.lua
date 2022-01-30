-- Tests for the wordle helper

lu = require('luaunit')
helper = require('helper')

-------------------------------------------------------

TestWords = {}

Words = helper.Words

function TestWords:testNew()
    local words = Words.new({ "alice", "bob" })
    lu.assertEquals( words:contains("alice"), true )
    lu.assertEquals( words:contains("bob"), true )
    lu.assertEquals( words:contains("chloe"), false )
end

function TestWords:testRescore()
    local words = Words.new({ "alice", "lucky" })
    words:rescore()

    lu.assertEquals( words:freq('a'), 1 )
    lu.assertEquals( words:freq('c'), 2 )
    lu.assertEquals( words:freq('d'), 0 )
    lu.assertEquals( words:freq('l'), 2 )

    lu.assertEquals( words:score("alice"), 7)
    lu.assertEquals( words:score("ali"), 4)
    lu.assertEquals( words:score("luc"), 5)
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

end

-------------------------------------------------------

os.exit( lu.LuaUnit.run() )
