#!/bin/bash

PROG="./myexeclp"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo ".....OK"

######################################

echo -n "test 02 - program output: "

mkdir $OUTPUT/toto ; touch $OUTPUT/toto/tata ; touch $OUTPUT/toto/titi
ls -a $OUTPUT/toto > $OUTPUT/output1

! $PROG ls -a $OUTPUT/toto > $OUTPUT/output2 2> /dev/null && echo "KO -> exit code != 0 for ls -a"                                               && exit 1
! cmp -s $OUTPUT/output1 $OUTPUT/output2                  && echo "KO -> check files \"$OUTPUT/output2\" (yours) \"$OUTPUT/output1\" (expected)" && exit 1

echo salut tata titi toto > $OUTPUT/output1
! $PROG echo salut tata titi toto > $OUTPUT/output2 2> /dev/null && echo "KO -> exit code != 0 for echo"                                                && exit 1
! cmp -s $OUTPUT/output1 $OUTPUT/output2                         && echo "KO -> check files \"$OUTPUT/output2\" (yours) \"$OUTPUT/output1\" (expected)" && exit 1

echo "...OK"

######################################

echo -n "test 03 - check error cases: "

echo "myexeclp: No such file or directory" > $OUTPUT/error
LC_ALL=C $PROG $OUTPUT/abcd -l -g > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit code == 0 if command not found"                              && exit 1
! cmp -s $OUTPUT/error $OUTPUT/stderr                           && echo "KO -> error message should be: \"myexeclp: No such file or directory\"" && exit 1  

echo "myexeclp: Not a directory" > $OUTPUT/error
LC_ALL=C PATH=$OUTPUT/toto/tata $PROG echo coucou > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit code == 0 if regular file in PATH"                 && exit 1
! cmp -s $OUTPUT/error $OUTPUT/stderr                                           && echo "KO -> error message should be: \"myexeclp: Not a directory\"" && exit 1  

echo "myexeclp: Argument list too long" > $OUTPUT/error
LC_ALL=C $PROG echo 1 2 3 4 5 6 > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit code == 0 if nb_arg > MAX_ARG"                 && exit 1
! cmp -s $OUTPUT/error $OUTPUT/stderr                         && echo "KO -> error message should be: \"myexeclp: Argument list too long\"" && exit 1  

echo "OK"

######################################

echo -n "test 04 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG ls -la $OUTPUT > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo ".....OK"

######################################

rm -r $OUTPUT
