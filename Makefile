test:
	lua all-test.lua -v

run:
	lua -e "require('words').run()"

evaluate:
	lua -e "require('evaluator').runAndPlot(100)"
