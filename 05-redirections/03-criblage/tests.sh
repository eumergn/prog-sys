#!/bin/bash

PROG="./crible"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "...................OK"

######################################

echo -n "test 02 - fork failure: "

! grep "case -1:" $FILE > /dev/null && echo "KO -> no \"case -1\" found for fork ()" && exit 1

echo "...................OK"

######################################

echo -n "test 03 - program creates child processes: "

! grep "sleep" $FILE > /dev/null && echo "KO -> child should call sleep (1) before using pipe" && exit 1
$PROG 16 > /dev/null 2>&1 &
PID=$!

sleep 1

pgrep -P $PID > $OUTPUT/childs
NB=$(cat $OUTPUT/childs | wc -l)
[ $NB -ne 5 ] && echo "KO -> $NB child processes while 5 expected" && exit 1

wait $PID

echo "OK"

######################################

echo -n "test 04 - program output: "

cat <<EOF > $OUTPUT/output1
2
3
5
7
11
13
17
19
EOF

! $PROG 20 > $OUTPUT/output2 2> /dev/null && echo "KO -> exit code !=0" && exit 1
! cmp -s $OUTPUT/output1 $OUTPUT/output2  && echo "KO -> output differs, check \"$OUTPUT/output2\" (yours) and \"$OUTPUT/output1\" (expected)" && exit 1

echo ".................OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG < /bin/ls > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "...................OK"

######################################

rm -r $OUTPUT
