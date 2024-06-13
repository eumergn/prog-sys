#!/bin/bash

PROG="./compteur"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "....................OK"

######################################

echo -n "test 02 - program uses POSIX API: "

! grep sigaction $FILE > /dev/null && echo "KO -> you should use POSIX signals API" && exit 1

echo "..........OK"

######################################

echo -n "test 03 - program completes after 5 SIGINT: "

$PROG > $OUTPUT/output2 2> /dev/null &
PID=$!

sleep 1 ; kill -s SIGINT $PID
sleep 1 ; kill -s SIGINT $PID
sleep 1 ; kill -s SIGINT $PID
sleep 1 ; kill -s SIGINT $PID
sleep 1 ; kill -s SIGINT $PID

sleep 1 ; kill -s SIGTERM $PID 2> /dev/null
wait $PID
[ $? -ne 0 ] && echo "KO -> program still running" && exit 1

echo "OK"

######################################

echo -n "test 04 - program output: "

cat <<EOF > $OUTPUT/output1
compteur: 1
compteur: 2
compteur: 3
compteur: 4
compteur: 5
EOF

! cmp -s $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> outputs differ, check \"$OUTPUT/output2\" (yours) and \"$OUTPUT/output1\" (expected)" && exit 1

echo "..................OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG > /dev/null 2>&1 &
PID=$!

sleep 1 ; kill -s SIGINT $PID
sleep 1 ; kill -s SIGINT $PID
sleep 1 ; kill -s SIGINT $PID
sleep 1 ; kill -s SIGINT $PID
sleep 1 ; kill -s SIGINT $PID

[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "....................OK"

######################################

rm -r $OUTPUT
