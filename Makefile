test:
	lua all-test.lua -v

run:
	lua -e "require('words').run()"

evaluate:
	lua -e "require('evaluator').runAndPlot(100)"

evaluate-lowest-scoring:
	lua -e "Words = require('words') ; require('evaluator').runAndPlot(100, Words.lowestScoringWords)"
