#!/bin/bash

PROG="./moncat"
FILE="./moncat.c"

OUTPUT=/tmp/$$
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo ".........................OK"

######################################

echo -n "test 02 - program uses system calls: "
grep "fopen" $FILE && echo "KO -> program uses library functions instead of system calls"
echo "............OK"

echo -n "test 03 - program usage: "
$PROG > /dev/null 2> $OUTPUT/stderr              && echo "KO -> exit status == 0 if no arg"                   && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if no arg"         && exit 1
$PROG $OUTPUT/abcd > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if file not found"           && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if file not found" && exit 1
echo "........................OK"

echo -n "test 04 - program exits without error: "
echo "abcdefgh" > $OUTPUT/toto
! $PROG $OUTPUT/toto > $OUTPUT/titi 2> /dev/null && echo "KO -> exit status != 0" && exit 1
echo "..........OK"

echo -n "test 05 - program writes file content on stdout: "
! [ -s $OUTPUT/titi ] && echo "KO -> no output on stdout" && exit 1
echo "OK"

echo -n "test 06 - output is the same as file content: "
head -c 4096900 /dev/urandom > $OUTPUT/toto_b
! cmp -s $OUTPUT/toto $OUTPUT/titi                   && echo "KO -> output differs from source file, check files \"$OUTPUT/titi\" (yours) and \"$OUTPUT/toto\" (expected)"     && exit 1
! $PROG $OUTPUT/toto_b > $OUTPUT/titi_b 2> /dev/null && echo "KO -> exit status != 0 with large binary file"                                                                   && exit 1
! cmp -s $OUTPUT/toto_b $OUTPUT/titi_b               && echo "KO -> output differs from source file, check files \"$OUTPUT/titi_b\" (yours) and \"$OUTPUT/toto_b\" (expected)" && exit 1
echo "...OK"

echo -n "test 07 - execution time: "
t0=`date +%s`
$PROG $OUTPUT/toto_b > $OUTPUT/titi_b
t1=`date +%s`
runtime=$(($t1 - $t0))
[ $runtime -gt "1" ] && echo "KO -> execution time exceeds 1sec., are you reading by blocks?" && exit 1
echo ".......................OK"

echo -n "test 08 - memory error: "
! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG $OUTPUT/toto_b > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1
echo ".........................OK"

rm -r $OUTPUT
