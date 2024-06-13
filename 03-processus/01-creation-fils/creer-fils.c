#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/wait.h>
#include <unistd.h>

#define CHK(op)                                                                \
    do {                                                                       \
        if ((op) == -1) {                                                      \
            perror (#op);                                                      \
            exit (1);                                                          \
        }                                                                      \
    } while (0)

noreturn void raler (int syserr, const char *msg, ...)
{
    va_list ap;

    va_start (ap, msg);
    vfprintf (stderr, msg, ap);
    fprintf (stderr, "\n");
    va_end (ap);

    if (syserr == 1)
        perror ("");

    exit (EXIT_FAILURE);
}

int main (void)
{
    pid_t child;
    int status;
    switch ((child = fork ())) {
    case -1:
        raler (1, "ERREUR fork().\n");

    case 0:
        printf ("%jd %jd\n", (intmax_t)(getpid ()), (intmax_t)(getppid ()));
        sleep (1);
        exit (getpid () % 10);
    default:
        CHK (wait (&status));
        if (WIFEXITED (status)) {
            printf ("%d %d\n", child, WEXITSTATUS (status));
        }
    }
}
