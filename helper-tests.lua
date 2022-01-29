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

-------------------------------------------------------

os.exit( lu.LuaUnit.run() )
