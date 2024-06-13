#!/bin/bash

PROG="./creer-fils"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "..............OK"

######################################

echo -n "test 02 - fork failure: "

! grep "case -1:" $FILE > /dev/null && echo "KO -> no \"case -1\" found for fork ()" && exit 1

echo "..............OK"

######################################

echo -n "test 03 - printed PID and exit value: "

$PROG > $OUTPUT/output1 2> /dev/null &
PID=$!

CHILD=$(pgrep -P $PID)
[ -z "$CHILD" ] && echo "KO -> no child process" && exit 1
EXIT=$(expr $CHILD % 10)
printf "%s\n%s\n" "$CHILD $PID" "$CHILD $EXIT" > $OUTPUT/output2

wait $PID
! cmp $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> check files \"$OUTPUT/output1\" (yours) and \"$OUTPUT/output2\" (expected)" && exit 1

echo "OK"

######################################

echo -n "test 04 - print POSIX types: "

! grep "%jd"      $FILE > /dev/null && echo "KO -> print pid_t type using %jd and intmax_t" && exit 1
! grep "intmax_t" $FILE > /dev/null && echo "KO -> print pid_t type using %jd and intmax_t" && exit 1

echo ".........OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "..............OK"

######################################

rm -r $OUTPUT
