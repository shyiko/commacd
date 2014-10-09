shopt -s expand_aliases
. commacd.bash

ROOT=/tmp/commacd.shpec
rm -rf $ROOT
mkdir -p $ROOT/projects/{jekyll,ghost,mysql-binlog-connector-java/src/main/java,mappify/{.git,src/test}}
mkdir -p $ROOT/space\ hell/{a\ a,b\ b,a\ b}

COMMACD_CD=cd # supress pwd

describe 'commacd'

  describe ','
    it 'does nothing in case of no arguments'
      cd $ROOT
      ,
      assert equal "$PWD" $ROOT
    it 'stays in the same directory in case of no match'
      cd $ROOT
      , p/nonexisting
      assert equal "$PWD" $ROOT
    it 'changes directory without asking anything in case of single (unique) match'
      cd $ROOT
      , p/m/s/m
      assert equal "$PWD" "$ROOT/projects/mysql-binlog-connector-java/src/main"
    it 'supports patterns starting with /'
      cd $ROOT
      , $ROOT/p/j
      assert equal "$PWD" "$ROOT/projects/jekyll"
    it 'asks for user input in case of multiple choices'
      cd $ROOT
      , $ROOT/p/m 2> /dev/null <<< $(echo 0)
      assert equal "$PWD" "$ROOT/projects/mappify"
    it 'can be used in subshells'
      cd $ROOT
      commacd_to_restore=$COMMACD_CD
      COMMACD_CD=
      v=$(, p)
      COMMACD_CD=$commacd_to_restore
      assert equal "$v" "$ROOT/projects"
    it 'does not break on spaces'
      cd $ROOT
      , s/b
      assert equal "$PWD" "$ROOT/space hell/b b"
  end_describe

  describe ',,'
    it 'goes to the project root directory in case of no arguments'
      cd $ROOT/projects/mappify/src/test
      ,,
      assert equal "$PWD" "$ROOT/projects/mappify"
    it 'stays in the same directory in case of no match'
      cd $ROOT
      ,,
      ,, nonexisting
      assert equal "$PWD" $ROOT
    it 'always switches to the closest match'
      cd $ROOT/projects/mysql-binlog-connector-java/src/main/java
      ,, m
      assert equal "$PWD" $ROOT/projects/mysql-binlog-connector-java/src/main
    it 'performs substitution in case of two arguments'
      cd $ROOT/projects/jekyll
      ,, jekyll ghost
      assert equal "$PWD" $ROOT/projects/ghost
    it 'supports patterns starting with /'
      cd $ROOT/projects/mappify/src/test
      ,, $ROOT/projects/mappify
      assert equal "$PWD" "$ROOT/projects/mappify"
    it 'can be used in subshells'
      cd $ROOT/projects/jekyll
      commacd_to_restore=$COMMACD_CD
      COMMACD_CD=
      v=$(,, pro)
      COMMACD_CD=$commacd_to_restore
      assert equal "$v" "$ROOT/projects"
    it 'does not break on spaces'
      cd "$ROOT/space hell/b b"
      ,, s
      assert equal "$PWD" "$ROOT/space hell"
  end_describe

  describe ',,,'
     it 'does nothing in case of no arguments'
      cd $ROOT
      ,,,
      assert equal "$PWD" $ROOT
    it 'stays in the same directory in case of no match'
      cd $ROOT
      ,,, nonexisting
      assert equal "$PWD" $ROOT
    it 'changes directory without asking anything in case of single (unique) match'
      cd $ROOT/projects/mappify/src/test
      ,,, mysql
      assert equal "$PWD" "$ROOT/projects/mysql-binlog-connector-java"
    it 'supports patterns starting with /'
      cd $ROOT/projects/mappify
      ,,, $ROOT/projects/mysql
      assert equal "$PWD" "$ROOT/projects/mysql-binlog-connector-java"
    it 'asks for user input in case of multiple choices'
      cd $ROOT/projects/jekyll
      ,,, m 2> /dev/null <<< $(echo 0)
      assert equal "$PWD" "$ROOT/projects/mappify"
    it 'can be used in subshells'
      cd $ROOT/projects/jekyll
      commacd_to_restore=$COMMACD_CD
      COMMACD_CD=
      v=$(,,, mysql)
      COMMACD_CD=$commacd_to_restore
      assert equal "$v" "$ROOT/projects/mysql-binlog-connector-java"
    it 'does not break on spaces'
      cd "$ROOT/space hell/a a"
      ,,, b
      assert equal "$PWD" "$ROOT/space hell/b b"
  end_describe

end_describe
