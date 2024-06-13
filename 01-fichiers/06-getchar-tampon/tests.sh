#!/bin/bash

PROG="./getchar"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

echo -n "test 01 - coding style: "
! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1
echo "....................OK"

echo -n "test 02 - program uses system calls: "
grep "fopen" $FILE > /dev/null && echo "KO -> program uses library functions instead of system calls" && exit 1
echo ".......OK"

echo -n "test 03 - text file as input: "
echo abcdefgh > $OUTPUT/input
! $PROG < $OUTPUT/input > $OUTPUT/output 2> /dev/null && echo "KO -> exit status != 0" && exit 1
! cmp -s $OUTPUT/input $OUTPUT/output                 && echo "KO -> output differs from input, checks files \"$OUTPUT/input\" and \"$OUTPUT/output\"" && exit 1
echo "..............OK"

echo -n "test 04 - binary file as input: "
head -c 4094303 /dev/urandom > $OUTPUT/input_b
! $PROG < $OUTPUT/input_b > $OUTPUT/output 2> /dev/null && echo "KO -> exit status != 0" && exit 1
! cmp -s $OUTPUT/input_b $OUTPUT/output                 && echo "KO -> output differs from input, checks files \"$OUTPUT/input_b\" and \"$OUTPUT/output\"" && exit 1
echo "............OK"

echo -n "test 05 - execution time lower than 1 sec.: "
t0=`date +%s`
! $PROG < $OUTPUT/input_b > $OUTPUT/output 2> /dev/null && echo "KO -> exit status != 0" && exit 1
t1=`date +%s`
runtime=$(($t1 - $t0))
[ $runtime -gt "1" ] && echo "KO -> increase buffer size" && exit 1
echo "OK"

echo -n "test 06 - memory error: "
! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG < $OUTPUT/input_b > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1
echo "....................OK"

rm -r $OUTPUT