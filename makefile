all: lint test

lint:
	test -s `which shellcheck` || { echo "shellcheck (https://github.com/koalaman/shellcheck) wasn't found on the PATH. Please install it and try again."; exit 1; }
	shellcheck -s bash -e SC2128 -e SC2178 -e SC2162 -f gcc commacd.bash

test:
	test -s `which shpec` || { echo "shpec (https://github.com/rylnd/shpec) wasn't found on the PATH. Please install it and try again"; exit 1; }
	bash -i -c "shpec"
