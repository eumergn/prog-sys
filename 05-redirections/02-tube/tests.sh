#!/bin/bash

PROG="./tube"
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

echo -n "test 02 - fork failure: "

! grep "case -1:" $FILE > /dev/null && echo "KO -> no \"case -1\" found for fork ()" && exit 1

echo ".................OK"

######################################

echo -n "test 03 - program creates child process: "

! grep "sleep" $FILE > /dev/null && echo "KO -> child should call sleep (1) before using pipe" && exit 1
$PROG < /bin/ls > $OUTPUT/output 2>&1 &
PID=$!

sleep 1

CHILD=$(pgrep -P $PID)
[ -z "$CHILD" ] && echo "KO -> no child process" && exit 1

wait $PID

echo "OK"

######################################

echo -n "test 04 - program output: "

! cmp -s /bin/ls $OUTPUT/output && echo "KO -> output differs, check \"$OUTPUT/output\" (yours) and \"/bin/ls\" (expected)" && exit 1

echo "...............OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG < /bin/ls > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo ".................OK"

######################################

rm -r $OUTPUT
