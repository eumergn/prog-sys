#!/bin/bash

PROG="./liste-rep"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "................OK"

######################################

echo -n "test 02 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr                 && echo "KO -> exit status == 0 if no arg"                        && exit 1
! [ -s $OUTPUT/stderr ]                             && echo "KO -> no error message on stderr if no arg"              && exit 1

$PROG 1 > /dev/null 2> $OUTPUT/stderr               && echo "KO -> exit status == 0 if one arg"                       && exit 1
! [ -s $OUTPUT/stderr ]                             && echo "KO -> no error message on stderr if one arg"             && exit 1

$PROG 1 2 3 > /dev/null 2> $OUTPUT/stderr           && echo "KO -> exit status == 0 if more than 2 args"              && exit 1
! [ -s $OUTPUT/stderr ]                             && echo "KO -> no error message on stderr if more than 2 args"    && exit 1

$PROG $OUTPUT/abcd 1 > /dev/null 2> $OUTPUT/stderr  && echo "KO -> exit status == 0 if directory not found"           && exit 1
! [ -s $OUTPUT/stderr ]                             && echo "KO -> no error message on stderr if directory not found" && exit 1

$PROG $OUTPUT 0 > /dev/null 2> $OUTPUT/stderr       && echo "KO -> exit status == 0 if depth < 1"                     && exit 1
! [ -s $OUTPUT/stderr ]                             && echo "KO -> no error message on stderr if depth < 1"           && exit 1

$PROG $OUTPUT 10 > /dev/null 2> $OUTPUT/stderr      && echo "KO -> exit status == 0 if depth > 9"                     && exit 1
! [ -s $OUTPUT/stderr ]                             && echo "KO -> no error message on stderr if depth > 9"           && exit 1

echo "...............OK"

######################################

echo -n "test 03 - program success with depth 1: "

find $OUTPUT -maxdepth 2 -type d > $OUTPUT/output2

! $PROG $OUTPUT 1 > $OUTPUT/output1 2>&1 && echo "KO -> exit status != 0"                                                        && exit 1
! cmp -s $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> outputs differ, check \"$OUTPUT/output1\" and \"$OUTPUT/output2\" files" && exit 1

echo "OK"

######################################

echo -n "test 04 - program success with depth 5: "

mkdir -p $OUTPUT/1/2/3/4/5 ; mkdir -p $OUTPUT/1bis/2bis/3bis ; touch $OUTPUT/1bis/2bis/toto

find $OUTPUT -maxdepth 5 -type d > $OUTPUT/output2
! $PROG $OUTPUT 5 > $OUTPUT/output1 2>&1 && echo "KO -> exit status != 0"                                                        && exit 1
! cmp -s $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> outputs differ, check \"$OUTPUT/output1\" and \"$OUTPUT/output2\" files" && exit 1

echo "OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG $OUTPUT 5 > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "................OK"

######################################

rm -r $OUTPUT