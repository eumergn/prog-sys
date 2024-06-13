#!/bin/bash

PROG="./coupleur"
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

echo -n "test 02 - program uses POSIX API: "

! grep sigaction $FILE > /dev/null  && echo "KO -> you should use POSIX signals API" && exit 1
! grep sigsuspend $FILE > /dev/null && echo "KO -> you should use POSIX signals API" && exit 1

echo ".......OK"

######################################

echo -n "test 03 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr    && echo "KO -> exit status == 0 if no arg"            && exit 1
! [ -s $OUTPUT/stderr ]                && echo "KO -> no error message on stderr if no arg"  && exit 1

$PROG -1 > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if value not in [0;255]"           && exit 1
! [ -s $OUTPUT/stderr ]                && echo "KO -> no error message on stderr if value not in [0;255]" && exit 1

echo "................OK"

######################################

echo -n "test 04 - fork failure: "

! grep "case -1:" $FILE > /dev/null && echo "KO -> no \"case -1\" found for fork ()" && exit 1

echo ".................OK"

######################################

echo -n "test 05 - program creates child process: "

$PROG 32 > /dev/null 2>&1 &
PID=$!
sleep 1

NB=$(pgrep -P $PID | wc -l)
[ $NB -ne 1 ] && echo "KO -> $NB child processes while 1 expected" && exit 1

wait $PID

echo "OK"

######################################

echo -n "test 06 - program output: "

echo "247" > $OUTPUT/output1
! $PROG 247 > $OUTPUT/output2 2> /dev/null && echo "KO -> exit status != 0"                      && exit 1
! cmp -s $OUTPUT/output1 $OUTPUT/output2   && echo "KO -> value printed by child process != 247" && exit 1

echo "...............OK"

######################################

echo -n "test 07 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG 131 > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "..................OK"

######################################

rm -r $OUTPUT
