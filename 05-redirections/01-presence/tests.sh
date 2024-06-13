#!/bin/bash

PROG="./presence"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "..OK"

######################################

echo -n "test 02 - fork failure: "

! grep "case -1:" $FILE > /dev/null && echo "KO -> no \"case -1\" found for fork ()" && exit 1

echo "..OK"

######################################

echo -n "test 03 - program usage: "

$PROG  > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit code == 0 if no arg"             && exit 1
! [ -s $OUTPUT/stderr ]              && echo "KO -> no error message on stderr if no arg" && exit 1

echo ".OK"

######################################

echo -n "test 04 - program output: "

$PROG toto > /dev/null 2>&1 && echo "KO -> exit code == 0 for unknown user"        && exit 1
! [ -s toto ]               && echo "KO -> file $OUTPUT/toto not created or empty" && exit 1

USR=$(whoami)
echo "$USR is connected" > $OUTPUT/output1

! $PROG $USR > $OUTPUT/output2 2> /dev/null && echo "KO -> exit code != 0 for root"                                                              && exit 1
! cmp -s $OUTPUT/output1 $OUTPUT/output2    && echo "KO -> output differs, check \"$OUTPUT/output2\" (yours) and \"$OUTPUT/output1\" (expected)" && exit 1

echo "OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG root > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "..OK"

######################################

rm -r $OUTPUT toto
