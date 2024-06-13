#!/bin/bash

PROG="./monls"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "............................OK"

######################################

echo -n "test 02 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr              && echo "KO -> exit status == 0 if no arg"                        && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if no arg"              && exit 1

$PROG $OUTPUT/abcd > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if directory not found"           && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if directory not found" && exit 1

echo "...........................OK"

######################################

echo -n "test 03 - program exits with status 0 on directory: "

! $PROG $OUTPUT > /dev/null 2>&1 && echo "KO -> exit status != 0" && exit 1

echo "OK"

######################################

echo -n "test 04 - check output: "

mkdir $OUTPUT/titi ; touch $OUTPUT/titi/tata ; touch $OUTPUT/titi/tutu

$PROG $OUTPUT/titi | sort -d > $OUTPUT/student
ls $OUTPUT/titi | sort -d > $OUTPUT/original
! cmp -s $OUTPUT/original $OUTPUT/student && echo "KO -> outputs differ, check file \"$OUTPUT/original\" (expected) and \"$OUTPUT/student\" (yours)" && exit 1

echo "............................OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG $OUTPUT > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "............................OK"

######################################

rm -r $OUTPUT
