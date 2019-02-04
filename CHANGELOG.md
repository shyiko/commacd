# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2019-02-03

### Added
- ZSH support ([#16](https://github.com/shyiko/commacd/pull/16)).
- `COMMACD_MARKER` env variable to control exit condition for `,,`  
(by default `,,` stops when it finds parent dir with `.git/`, `.hg/` or `.svn/`)

  ```
  $ tree -A ~
  |- a
     |- b
        |- c
           |- projects        # ,, should stop here (contains .git/)
              |- .commacdroot
              |- project_a    # and here (contains .commacdroot)
                 |- .git
                 |- x
                    |- y
                       |- z   # workdir

  $ export COMMACD_MARKER=".git/ .hg/ .svn/ .commacdroot" 
  
  ~/a/b/c/projects/project_a/x/y/z$ ,,
    => cd ~/a/b/c/projects/project_a
  
  ~/a/b/c/projects/project_a$ ,,
    => cd ~/a/b/c/projects
  ```

### Changed
- Default `COMMACD_CD` to print `commacd: no matches found` & exit with code 1 when there is no match.

## [0.4.0] - 2018-01-13

### Added
- Selection without <kbd>Enter</kbd> (when number of options is less than 10) (to enable `export COMMACD_IMPLICITENTER="on"`) ([#15](https://github.com/shyiko/commacd/issues/15)).

## [0.3.4] - 2018-01-05

### Fixed
- Error message is printed when `failglob` shell option is set and no matches are found ([#13](https://github.com/shyiko/commacd/pull/13)).

## [0.3.3] - 2017-10-07

### Fixed
- Terminal in inconsistent state after interrupt signal (`^C`) ([#12](https://github.com/shyiko/commacd/issues/12)).

## [0.3.2] - 2016-05-29

### Fixed
- COMMACD_CD handling [#10](https://github.com/shyiko/commacd/issues/10) (thanks to [@chilicuil](https://github.com/chilicuil)).

## [0.3.1] - 2015-08-29

### Fixed
- VCS root lookup (`,,`) in case of nested checkouts (`/.../checkout_1/.../checkout_2`).

## [0.3.0] - 2015-07-14

### Added
- A way to change enumeration of "multiple choices" to start from 1 (instead of default 0) (use `export COMMACD_SEQSTART=1` to activate) (thanks to [@skorochkin](https://github.com/skorochkin)).

## [0.2.1] - 2014-11-08

## Fixed
- Order of `,,`'s prefix/substring matching.

## [0.2.0] - 2014-11-07

## Added
- Substring (fuzzy) matching as a fallback to the default prefix lookup (can be turned off with `export COMMACD_NOFUZZYFALLBACK="on"`).

## 0.1.0 - 2014-11-07

[1.0.0]: https://github.com/shyiko/commacd/compare/v0.4.0...v1.0.0
[0.4.0]: https://github.com/shyiko/commacd/compare/v0.3.4...v0.4.0
[0.3.4]: https://github.com/shyiko/commacd/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/shyiko/commacd/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/shyiko/commacd/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/shyiko/commacd/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/shyiko/commacd/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/shyiko/commacd/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/shyiko/commacd/compare/v0.1.0...v0.2.0
