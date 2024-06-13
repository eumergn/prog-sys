#!/bin/bash

PROG="./testr"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "...............OK"

######################################

echo -n "test 02 - program uses system calls: "

grep "fopen" $FILE && echo "KO -> program uses library functions instead of system calls"

echo "..OK"

######################################

echo -n "test 03 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr              && echo "KO -> exit status == 0 if no arg"                   && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if no arg"         && exit 1

$PROG $OUTPUT/abcd > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if file not found"           && exit 1
! [ -s $OUTPUT/stderr ]                          && echo "KO -> no error message on stderr if file not found" && exit 1

echo "..............OK"

######################################

echo -n "test 04 - program exits without error: "

echo "abcdefgh" > $OUTPUT/toto
! $PROG $OUTPUT/toto > $OUTPUT/titi 2> /dev/null && echo "KO -> exit status != 0" && exit 1

echo "OK"

######################################

echo -n "test 05 - program writes on stdout: "

! [ -s $OUTPUT/titi ] && echo "KO -> no output on stdout" && exit 1

echo "...OK"

######################################

echo -n "test 06 - output for readable file: "

chmod -w $OUTPUT/toto
! $PROG $OUTPUT/toto > $OUTPUT/titi 2> /dev/null && echo "KO -> exit status != 0" && exit 1

chmod +w $OUTPUT/toto
MSG=`cat $OUTPUT/titi`
[ "$MSG" != "$OUTPUT/toto: R-" ] && echo "KO -> output differ from format: filename R-" && exit 1

echo "...OK"

######################################

echo -n "test 07 - output for writable file: "

chmod -r $OUTPUT/toto
! $PROG $OUTPUT/toto > $OUTPUT/titi 2> /dev/null && echo "KO -> exit status != 0" && exit 1
chmod +r $OUTPUT/toto
MSG=`cat $OUTPUT/titi`
[ "$MSG" != "$OUTPUT/toto: -W" ] && echo "KO -> output differ from format: filename -W" && exit 1

echo "...OK"

######################################

echo -n "test 08 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG $OUTPUT/toto > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "...............OK"

######################################

rm -r $OUTPUT
