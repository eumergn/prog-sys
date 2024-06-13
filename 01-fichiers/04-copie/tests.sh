#!/bin/bash

PROG="./copie"
FILE="$PROG.c"

OUTPUT=/tmp/$$
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "............................OK"

######################################

echo -n "test 02 - program uses system calls: "

grep "fopen" $FILE && echo "KO -> program uses library functions instead of system calls"

echo "...............OK"

######################################

echo -n "test 03 - program usage: "

LC_ALL=C tr -dc "A-Za-z0-9 \n\t\r" < /dev/urandom | head -c 1024300 > $OUTPUT/toto ; touch $OUTPUT/tata ; chmod -w $OUTPUT/tata

$PROG > /dev/null 2> $OUTPUT/stderr                           && echo "KO -> exit status == 0 if no arg"                                  && exit 1
! [ -s $OUTPUT/stderr ]                                       && echo "KO -> no error message on stderr if no arg"                        && exit 1

$PROG $OUTPUT/toto > /dev/null 2> $OUTPUT/stderr              && echo "KO -> exit status == 0 if only one arg"                            && exit 1
! [ -s $OUTPUT/stderr ]                                       && echo "KO -> no error message on stderr if only one arg"                  && exit 1

$PROG $OUTPUT/abcd $OUTPUT/titi > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if source file not found"                   && exit 1
! [ -s $OUTPUT/stderr ]                                       && echo "KO -> no error message on stderr if source file not found"         && exit 1

$PROG $OUTPUT/toto $OUTPUT/tata > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status != 0 if destination file not writable"           && exit 1
! [ -s $OUTPUT/stderr ]                                       && echo "KO -> no error message on stderr if destination file not writable" && exit 1 

echo "...........................OK"

######################################

echo -n "test 04 - program exits without error: "

! $PROG $OUTPUT/toto $OUTPUT/titi > /dev/null 2>&1 && echo "KO -> exit status != 0" && exit 1

echo ".............OK"

######################################

echo -n "test 05 - dest file is created with default rights: "

! [ -r $OUTPUT/titi ] && echo "KO -> destination file not created or not readable" && exit 1
! [ -w $OUTPUT/titi ] && echo "KO -> destination file not created or not writable" && exit 1
[ -x $OUTPUT/titi ]   && echo "KO -> x right is set for destination file"          && exit 1

echo "OK"

######################################

echo -n "test 06 - program writes in destination file: "

! [ -s $OUTPUT/titi ] && echo "KO -> no data in destination file" && exit 1

echo "......OK"

######################################

echo -n "test 07 - source and destination files are similar: "

head -c 1024300 /dev/urandom > $OUTPUT/toto_b

! cmp $OUTPUT/toto $OUTPUT/titi       && echo "KO -> files differ on ASCII files, check files \"$OUTPUT/titi\" (yours) and \"$OUTPUT/toto\" (expected)" && exit 1
! $PROG $OUTPUT/toto_b $OUTPUT/titi_b && echo "KO -> exit status !=0 with binary file"                                               && exit 1 
! cmp $OUTPUT/toto_b $OUTPUT/titi_b   && echo "KO -> files differ on binary files, check files \"$OUTPUT/titi_b\" (yours) and \"$OUTPUT/toto_b\" (expected)" && exit 1

echo "OK"

######################################

echo -n "test 08 - execution time: "

t0=`date +%s`
$PROG $OUTPUT/toto_b $OUTPUT/titi_b > /dev/null 2>&1
t1=`date +%s`
runtime=$(($t1 - $t0))
[ $runtime -gt "1" ] && echo "KO -> execution time exceeds 1sec., are you reading by blocks?" && exit 1

echo "..........................OK"

######################################

echo -n "test 09 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG $OUTPUT/toto_b $OUTPUT/titi_b > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "............................OK"

######################################

yes | rm -r $OUTPUT
