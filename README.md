# commacd [![Build Status](https://travis-ci.org/shyiko/commacd.svg)](https://travis-ci.org/shyiko/commacd)

A faster way to move around (Bash 3+/Zsh).

> `commacd` is NOT an [autojump](https://github.com/joelthelion/autojump)/[z](https://github.com/rupa/z)/[fasd](https://github.com/clvv/fasd) alternative nor they are mutually exclusive. Think of it as an improved `cd`.

## Installation

#### Bash

```sh
curl -sSL https://github.com/shyiko/commacd/raw/v1.0.0/commacd.sh -o ~/.commacd.sh && \
  echo "source ~/.commacd.sh" >> ~/.bashrc
```

> macOS users: make sure [~/.bashrc is sourced from ~/.bash_profile](http://ss64.com/osx/syntax-bashrc.html).

#### Zsh

```sh
curl -sSL https://github.com/shyiko/commacd/raw/v1.0.0/commacd.sh -o ~/.commacd.sh && \
  echo "source ~/.commacd.sh" >> ~/.zshrc
```

## Upgrading to the latest version

```sh
curl -sSL https://github.com/shyiko/commacd/raw/v1.0.0/commacd.sh -o ~/.commacd.sh
```

## Usage

`commacd` exports three commands: `,` (for jumping forward), `,,` (backward) and `,,,` (backward+forward):

> All three of them try to match by prefix first. Only if no results are found, will they fallback to substring (fuzzy) matching (0.2.0+).

```sh
~$ , des
  => cd Desktop

# move through multiple directories
~$ , /u/l/ce
  => cd /usr/local/Cellar

# allow me to choose directory in case of ambiguous pattern (= multiple choices)
~$ , d
  => 1 Desktop
     2 Downloads
     : <type index of the directory to cd into>

# given two directories jdk7 and jdk8 on the Desktop, cd into jdk8 without hitting
# interactive mode (the one shown above)
~/github$ , ~/d/j*8
  => cd ~/Desktop/jdk8

# cd into directory having 'esk' somewhere in its name
~/github$ , ~/esk # in pre-0.2.0 that would be `, ~/*esk`
  => cd ~/Desktop

# go all the way up to the project root (in this case, the one that has .git in it)
~/github/lorem/src/public$ ,,
  => cd ~/github/lorem

# cd into to the first (closest) parent directory named g*
~/github/vimium/src/public$ ,, g
  => cd ~/github

# substitute jekyll with ghost
~/github/jekyll/test$ ,, jekyll ghost
  => cd ~/github/ghost/test

# jump to some other project (in this case, located in ~/github)
~/github/rook/src/public$ ,,, binlog # in pre-0.2.0 you would need to use `m*binlog`
  => cd ~/github/mysql-binlog-connector-java
```

As a bonus, all three aliases support `<Tab>` expansion (try `, /u/lo<Tab>`) and can be combined with other tools (e.g. ``ls `, /u/lo` ``).

For more information, please refer to http://shyiko.com/2014/10/10/commacd/.

## Development

```sh
make # lint & test
```

## License

[MIT License](http://opensource.org/licenses/mit-license.php)

