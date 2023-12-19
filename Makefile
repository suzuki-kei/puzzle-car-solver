
.DEFAULT_GOAL := test

.PHONY: test
test:
	@ruby -I src/main -I src/test src/test/all.rb

.PHONY: solve
solve:
	@ruby -I src/main/ src/main/main.rb solve

.PHONY: normalize-problem-files
normalize-problem-files:
	@ruby -I src/main/ src/main/main.rb normalize-problem-files

