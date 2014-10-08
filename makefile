all: lint test

lint:
	test -s `which shellcheck` || { echo "shellcheck (https://github.com/koalaman/shellcheck) wasn't found on the PATH. Please install it and try again."; exit 1; }
	shellcheck -e SC2128 -f gcc commacd.bash

test:
	test -s `which shpec` || { echo "shpec (https://github.com/rylnd/shpec) wasn't found on the PATH. Please install it and try again"; exit 1; }
	shpec
