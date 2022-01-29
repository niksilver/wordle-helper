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

-------------------------------------------------------

os.exit( lu.LuaUnit.run() )
