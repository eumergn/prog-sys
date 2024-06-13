#!/bin/bash

PROG="./liste"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "...................OK"

######################################

echo -n "test 02 - program completes: "

$PROG > $OUTPUT/stdout 2> $OUTPUT/stderr &
PID=$!

sleep 20 ; kill -s 9 $PID 2> /dev/null
! wait $PID 2> /dev/null && echo "KO -> program loops" && exit 1

echo "..............OK"

######################################

echo -n "test 03 - program creates child processes: "

$PROG > /dev/null  2>&1 &
PID=$!
sleep 2

NB=$(pgrep -P $PID | wc -l)
[ $NB -ne 29 ] && echo "KO -> $NB child processes while 29 expected" && exit 1

wait $PID

echo "OK"

######################################

echo -n "test 04 - program output: "

! [ -s $OUTPUT/stdout ] && echo "KO -> no output on stdout" && exit 1 

NB=$(grep "START" $OUTPUT/stdout | wc -l)
[ $NB -ne 29 ] && echo "KO -> not enough child started" && exit 1

NB=$(grep "END" $OUTPUT/stdout | wc -l)
[ $NB -ne 29 ] && echo "KO -> not enough child started" && exit 1

NB=$(grep "type 0" $OUTPUT/stdout | cut -d ' ' -f3)
[ $NB -ne 1000000 ] && echo "KO -> not 1000000 iter of type 0" && exit 1

echo ".................OK"

######################################

echo -n "test 05 - inconsistencies on type 0: " 

[ -s $OUTPUT/stderr ] && echo "KO -> inconsistencies detected, check \"$OUTPUT/stderr\"" && exit 1

echo "......OK"

# ######################################

echo -n "test 06 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "...................OK"

######################################

rm -r $OUTPUT
