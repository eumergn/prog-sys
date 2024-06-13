#!/bin/bash

PROG="./execmd"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: true, SpaceBeforeSquareBrackets: true, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "..OK"

######################################

echo -n "test 02 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr              && echo "KO -> exit status == 0 if no arg"                  && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if no arg"        && exit 1

#$PROG $OUTPUT/abcd > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if cmd not found"           && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if cmd not found" && exit 1

echo ".OK"

######################################

echo -n "test 03 - program output: "

mkdir $OUTPUT/ls ; touch $OUTPUT/ls/toto ; touch $OUTPUT/ls/tata ; ls $OUTPUT/ls > $OUTPUT/output1

$PROG ls $OUTPUT/ls > $OUTPUT/output2
! cmp -s $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> check files \"$OUTPUT/output2\" (yours) \"$OUTPUT/output1\" (expected)" && exit 1

echo "OK"

######################################

echo -n "test 04 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG ls $OUTPUT/output > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "..OK"

######################################

rm -r $OUTPUT
