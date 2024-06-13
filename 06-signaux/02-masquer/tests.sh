#!/bin/bash

PROG="./masquer"
FILE="$PROG.c"

OUTPUT="/tmp/$$"
mkdir $OUTPUT

######################################

echo -n "test 01 - coding style: "

! which clang-format > /dev/null && echo "KO -> please install clang-format" && exit 1
clang-format --style='{BasedOnStyle: llvm, IndentWidth: 4, SpaceBeforeParens: Always, SpaceAfterLogicalNot: True, SpaceBeforeSquareBrackets: True, BreakBeforeBraces: Linux }' $FILE > $OUTPUT/result
! cmp -s $FILE $OUTPUT/result && echo "KO -> check files \"$FILE\" (yours) \"$OUTPUT/result\" (expected)" && exit 1

echo "..................OK"

######################################

echo -n "test 02 - program uses POSIX API: "

grep sigaction $FILE > /dev/null     && echo "KO -> you should not use sigaction here" && exit 1
! grep sigprocmask $FILE > /dev/null && echo "KO -> you should use sigprocmask"        && exit 1

echo "........OK"

######################################

echo -n "test 03 - program output for SIGINT: "

cat <<EOF > $OUTPUT/output1
Interrupt
EOF

LC_ALL=C $PROG > $OUTPUT/output2 2> /dev/null &
PID=$!
sleep 1 ; kill -s 2 $PID

! wait $PID 2> /dev/null && echo "KO -> signal not masked" && exit 1

! cmp -s $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> outputs differ, check \"$OUTPUT/output2\" (yours) and \"$OUTPUT/output1\" (expected" && exit 1

echo ".....OK"

######################################

echo -n "test 04 - program output for all signals: "

cat <<EOF > $OUTPUT/output1
Hangup
Interrupt
Quit
Illegal instruction
Trace/breakpoint trap
Aborted
Bus error
Floating point exception
User defined signal 1
Segmentation fault
User defined signal 2
Broken pipe
Alarm clock
Terminated
Stack fault
Child exited
Stopped
Stopped (tty input)
Stopped (tty output)
Urgent I/O condition
CPU time limit exceeded
File size limit exceeded
Virtual timer expired
Profiling timer expired
Window changed
I/O possible
Power failure
Bad system call
EOF

LC_ALL=C $PROG > $OUTPUT/output2 2> /dev/null &
PID=$!

sleep 1
for i in $(seq 1 31); do
    if [ $i -ne 9 -a $i -ne 19 ]; then
	kill -s $i $PID
    fi
done

! wait $PID 2> /dev/null && echo "KO -> signal not masked" && exit 1

! cmp -s $OUTPUT/output1 $OUTPUT/output2 && echo "KO -> outputs differ, check \"$OUTPUT/output2\" (yours) and \"$OUTPUT/output1\" (expected" && exit 1

echo "OK"

######################################

echo -n "test 05 - memory error: "

! which valgrind > /dev/null && echo "KO -> please install valgrind" && exit 1
valgrind --leak-check=full --error-exitcode=100 --log-file=$OUTPUT/valgrind.log $PROG > /dev/null 2>&1
[ "$?" == "100" ] && echo "KO -> memory pb please check $OUTPUT/valgrind.log" && exit 1

echo "..................OK"

######################################

rm -r $OUTPUT
