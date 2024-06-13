#!/bin/bash

PROG="./parexec"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "......................OK"

######################################

echo -n "test 02 - program usage: "

$PROG > /dev/null 2> $OUTPUT/stderr                && echo "KO -> exit status == 0 if no arg"                  && exit 1
! [ -s $OUTPUT/stderr ]                            && echo "KO -> no error message on stderr if no arg"        && exit 1

$PROG 4 > /dev/null 2> $OUTPUT/stderr              && echo "KO -> exit status == 0 if one arg"                 && exit 1
! [ -s $OUTPUT/stderr ]                            && echo "KO -> no error message on stderr if one arg"       && exit 1

$PROG 0 ls > /dev/null 2> $OUTPUT/stderr           && echo "KO -> exit status == 0 if n == 0"                  && exit 1
! [ -s $OUTPUT/stderr ]                            && echo "KO -> no error message on stderr if n == 0"        && exit 1

$PROG 10 ls > /dev/null 2> $OUTPUT/stderr          && echo "KO -> exit status == 0 if n == 10"                 && exit 1
! [ -s $OUTPUT/stderr ]                            && echo "KO -> no error message on stderr if n == 10"       && exit 1

$PROG 3 $OUTPUT/abcd > /dev/null 2> $OUTPUT/stderr && echo "KO -> exit status == 0 if cmd not found"           && exit 1
! [ -s $OUTPUT/stderr ]                            && echo "KO -> no error message on stderr if cmd not found" && exit 1

echo ".....................OK"

######################################

echo -n "test 03 - program output: "

cat <<EOF > $OUTPUT/output1
salut 0
salut 1
salut 2
salut 3
salut 4
EOF

$PROG 5 echo salut | sort -d > $OUTPUT/output2 
! cmp -s $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> check files \"$OUTPUT/output2\" (yours) \"$OUTPUT/output1\" (expected)" && exit 1

echo "....................OK"

######################################

echo -n "test 04 - program return code if child fails: "

cat << 'EOF' > $OUTPUT/cmd.sh
#!/bin/bash
exit $1
EOF
chmod +x $OUTPUT/cmd.sh

$PROG 2 $OUTPUT/cmd.sh > /dev/null 2>&1
[ $? -ne "1" ] && echo "KO -> return code should be 1" && exit 1

echo "OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --trace-children=yes --log-file=$OUTPUT/valgrind.log $PROG ls $OUTPUT/output > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "......................OK"

######################################

rm -r $OUTPUT
