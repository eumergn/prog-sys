#!/bin/bash

PROG="./nfils"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "................OK"

######################################

echo -n "test 02 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr    && echo "KO -> exit status == 0 if no arg"           && exit 1
! [ -s $OUTPUT/stderr ]                && echo "KO -> no error message on stderr if no arg" && exit 1

$PROG 0 > /dev/null 2> $OUTPUT/stderr  && echo "KO -> exit status == 0 if n < 1"            && exit 1
! [ -s $OUTPUT/stderr ]                && echo "KO -> no error message on stderr if n < 1"  && exit 1

$PROG 10 > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if n > 9"            && exit 1
! [ -s $OUTPUT/stderr ]                && echo "KO -> no error message on stderr if n > 9"  && exit 1

echo "...............OK"

######################################

echo -n "test 03 - fork failure: "

! grep "case -1:" $FILE > /dev/null && echo "KO -> no \"case -1\" found for fork ()" && exit 1

echo "................OK"

######################################

echo -n "test 04 - number of child processes: "

$PROG 5 > $OUTPUT/output1 2> /dev/null &
PID=$!

pgrep -P $PID | sort -d > $OUTPUT/childs
NB=$(cat $OUTPUT/childs | wc -l)
[ $NB -ne 5 ] && echo "KO -> $NB child processes while 5 expected" && exit 1

wait $PID

echo "...OK"

######################################

echo -n "test 05 - printed PIDs and exit status: "

cat $OUTPUT/output1 | cut -d ' ' -f1 | sort -d > $OUTPUT/pids
! cmp -s $OUTPUT/pids $OUTPUT/childs && echo "KO -> check files \"$OUTPUT/pids\" (yours) \"$OUTPUT/childs\" (expected)" && exit 1

cat $OUTPUT/output1 | cut -d ' ' -f2 > $OUTPUT/exits
! grep 0 $OUTPUT/exits > $OUTPUT/grep && echo "KO -> exit status differ from 0"                                         && exit 1

NB=$(cat $OUTPUT/grep | wc -l)
[ $NB -ne 5 ]                         && echo "KO -> exit status differ from 0"                                         && exit 1 

echo "OK"

######################################

echo -n "test 06 - print POSIX types: "

! grep "%jd"      $FILE > /dev/null && echo "KO -> print pid_t type using %jd and intmax_t" && exit 1
! grep "intmax_t" $FILE > /dev/null && echo "KO -> print pid_t type using %jd and intmax_t" && exit 1

echo "...........OK"

######################################

echo -n "test 07 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "................OK"

######################################

rm -r $OUTPUT
