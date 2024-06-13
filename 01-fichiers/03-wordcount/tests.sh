#!/bin/bash

PROG="./wordcount"
FILE="$PROG.c"

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

######################################

echo -n "test 03 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr              && echo "KO -> exit status == 0 if no arg"                   && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if no arg"         && exit 1

$PROG $OUTPUT/abcd > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if file not found"           && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if file not found" && exit 1

echo "........................OK"

######################################

echo -n "test 04 - program exits without error: "

LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r\f" < /dev/urandom | head -c 4096303 > $OUTPUT/toto 
! $PROG $OUTPUT/toto > $OUTPUT/titi 2> /dev/null && echo "KO -> exit status != 0" && exit 1

echo "..........OK"

######################################

echo -n "test 05 - program writes file content on stdout: "

! [ -s $OUTPUT/titi ] && echo "KO -> no output on stdout" && exit 1

echo "OK"

######################################

echo -n "test 06 - program counts line number: "

wc -l $OUTPUT/toto | cut -d ' ' -f1 > $OUTPUT/wc
cat   $OUTPUT/titi | cut -d ' ' -f1             > $OUTPUT/output
! cmp -s $OUTPUT/wc $OUTPUT/output && echo "KO -> numbers differ, check files \"$OUTPUT/output\" (yours) and \"$OUTPUT/wc\" (expected)" && exit 1

echo "...........OK"

######################################

echo -n "test 07 - program counts word number: "

wc -w $OUTPUT/toto | cut -d ' ' -f1 > $OUTPUT/wc
cat   $OUTPUT/titi | cut -d ' ' -f2             > $OUTPUT/output
! cmp -s $OUTPUT/wc $OUTPUT/output && echo "KO -> numbers differ, check files \"$OUTPUT/output\" (yours) and \"$OUTPUT/wc\" (expected)" && exit 1

echo "...........OK"

######################################

echo -n "test 08 - program counts byte number: "

wc -c $OUTPUT/toto | cut -d ' ' -f1 > $OUTPUT/wc
cat   $OUTPUT/titi | cut -d ' ' -f3             > $OUTPUT/output
! cmp -s $OUTPUT/wc $OUTPUT/output && echo "KO -> numbers differ, check files \"$OUTPUT/output\" (yours) and \"$OUTPUT/wc\" (expected)" && exit 1

echo "...........OK"

######################################

echo -n "test 09 - execution time: "

t0=`date +%s`
$PROG $OUTPUT/toto > /dev/null 2>&1
t1=`date +%s`
runtime=$(($t1 - $t0))
[ $runtime -gt "1" ] && echo "KO -> execution time exceeds 1sec., are you reading by blocks?" && exit 1

echo ".......................OK"

######################################

echo -n "test 10 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG $OUTPUT/toto_b > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo ".........................OK"

######################################

rm -r $OUTPUT
