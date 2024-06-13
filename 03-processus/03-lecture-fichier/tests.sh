#!/bin/bash

PROG="./lecture"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo ".................OK"

######################################

echo -n "test 02 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr              && echo "KO -> exit status == 0 if no arg"                   && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if no arg"         && exit 1

$PROG $OUTPUT/abcd > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if file not found"           && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if file not found" && exit 1

echo "................OK"

######################################

echo -n "test 03 - fork failure: "

! grep "case -1:" $FILE > /dev/null && echo "KO -> no \"case -1\" found for fork ()" && exit 1

echo ".................OK"

######################################

echo -n "test 04 - program creates child process: "

LC_ALL=C tr -dc "A-Za-z0-9\n" < /dev/urandom | head -c 1024000 > $OUTPUT/toto

$PROG $OUTPUT/toto > $OUTPUT/tata 2> /dev/null &
PID=$!

pgrep -P $PID | sort -d > $OUTPUT/childs
NB=$(cat $OUTPUT/childs | wc -l)
[ $NB -ne 1 ] && echo "KO -> $NB child processes while 1 expected" && exit 1

wait $PID

echo "OK"

######################################

echo -n "test 05 - program output: "

NC=$(cat $OUTPUT/tata | wc -c)
[ $NC -ne "1024000" ] && echo "KO -> check files \"$OUTPUT/tata\" (yours) \"$OUTPUT/toto\" (expected)" && exit 1

echo "...............OK"

######################################

echo -n "test 06 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG $OUTPUT/toto > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo ".................OK"

######################################

rm -r $OUTPUT
