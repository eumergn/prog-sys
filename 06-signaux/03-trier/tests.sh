#!/bin/bash

PROG="./trier"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "..................OK"

######################################

echo -n "test 02 - program uses POSIX API: "

! grep sigaction $FILE > /dev/null && echo "KO -> you should use POSIX signals API" && exit 1
! grep alarm $FILE > /dev/null     && echo "KO -> you should use POSIX signals API" && exit 1

echo "........OK"

######################################

echo -n "test 03 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr    && echo "KO -> exit status == 0 if no arg"            && exit 1
! [ -s $OUTPUT/stderr ]                && echo "KO -> no error message on stderr if no arg"  && exit 1

$PROG -1 > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if array size == -1"        && exit 1
! [ -s $OUTPUT/stderr ]                && echo "KO -> no error message on stderr array size == -1" && exit 1

echo ".................OK"

######################################

echo -n "test 04 - program output for small array: "

$PROG 5 > $OUTPUT/output2 2> /dev/null
sort -n $OUTPUT/output2 > $OUTPUT/output1

grep "working" $OUTPUT/output2 > /dev/null && echo "KO -> working statement present on small arrays"             && exit 1
! cmp -s $OUTPUT/output1 $OUTPUT/output2   && echo "KO -> array not sorted, check output in \"$OUTPUT/output2\"" && exit 1

echo "OK"

######################################

echo -n "test 05 - program output for large array: "

! $PROG 40960 > $OUTPUT/output 2> /dev/null && echo "KO -> program exit code != 0"         && exit 1
! grep "working" $OUTPUT/output > /dev/null && echo "KO -> no working statement on stdout" && exit 1

grep -v "working" $OUTPUT/output > $OUTPUT/output2 ; sort -n $OUTPUT/output2 > $OUTPUT/output1
! cmp -s $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> outputs differ, check \"$OUTPUT/output2\" (yours) and \"$OUTPUT/output1\" (expected)" && exit 1

echo "OK"

######################################

echo -n "test 06 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG 4096 > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "..................OK"

######################################

rm -r $OUTPUT
