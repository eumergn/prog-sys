#!/bin/bash

PROG="./copie-arbo"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "..................................OK"

######################################

echo -n "test 02 - program usage: "

mkdir $OUTPUT/source

$PROG > /dev/null 2> $OUTPUT/stderr                               && echo "KO -> exit status == 0 if no arg"                                         && exit 1
! [ -s $OUTPUT/stderr ]                                           && echo "KO -> no error message on stderr if no arg"                               && exit 1

$PROG $OUTPUT/source > /dev/null 2> $OUTPUT/stderr                && echo "KO -> exit status == 0 if only one arg"                                   && exit 1
! [ -s $OUTPUT/stderr ]                                           && echo "KO -> no error message on stderr if no arg"                               && exit 1

$PROG $OUTPUT/abcd $OUTPUT/cpy > /dev/null 2> $OUTPUT/stderr      && echo "KO -> exit status == 0 if source directory not found"                     && exit 1
! [ -s $OUTPUT/stderr ]                                           && echo "KO -> no error message on stderr if source directory not found"           && exit 1

$PROG $OUTPUT/source $OUTPUT/source > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if destination directory already exists"           && exit 1
! [ -s $OUTPUT/stderr ]                                           && echo "KO -> no error message on stderr if destination directory already exists" && exit 1

echo ".................................OK"

######################################

echo -n "test 03 - program success on a tree: "

mkdir -p $OUTPUT/source/1/2
head -c 102400 /dev/urandom > $OUTPUT/source/toto
head -c 500    /dev/urandom > $OUTPUT/source/1/titi
head -c 2050   /dev/urandom > $OUTPUT/source/1/2/tata

! $PROG $OUTPUT/source $OUTPUT/cpy > /dev/null 2>&1 && echo "KO -> exit status != 0" && exit 1

echo ".....................OK"

######################################

echo -n "test 04 - source and destination dir are similar: "

! diff -qr $OUTPUT/source $OUTPUT/cpy &> /dev/null  && echo "KO -> copy differs, check the output of \"diff -qr $OUTPUT/source $OUTPUT/cpy\"" && exit 1

rm -r $OUTPUT/cpy

echo "........OK"

######################################

echo -n "test 05 - program failure if source dir includes symlink: "

touch $OUTPUT/source/toto ; ln -s $OUTPUT/source/toto $OUTPUT/source/link

$PROG $OUTPUT/source $OUTPUT/cpy > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0"           && exit 1
! [ -s $OUTPUT/stderr ]                                        && echo "KO -> no error message on stderr" && exit 1

rm $OUTPUT/source/link $OUTPUT/source/toto
rm -r $OUTPUT/cpy

echo "OK"

######################################

echo -n "test 06 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG $OUTPUT/source $OUTPUT/cpy > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "..................................OK"

######################################

rm -r $OUTPUT
