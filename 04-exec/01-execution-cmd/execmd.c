#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
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

int main (int argc, char *argv [])
{
    if (argc < 2) {
        raler (1, "Erreur, nombre d'arguments...\n");
    }
    execvp (argv [1], &argv [+1]); // ca return -1 en cas d'erreur de execvp ou argv+1
    raler (1, "Erreur, nombre d'arguments...\n");

    return 0;
}
