#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/stat.h>
#define SIZE 1024

#define CHK(op)                                                                \
    do {                                                                       \
        if ((op) == -1)                                                        \
            raler (1, #op);                                                    \
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

    if (argc != 2) {
        raler (1, "NB D'ARGUMENTS!!! ");
    }

    const char *path_name = argv [1];
    struct stat stats;
    int st = stat (path_name, &stats);

    if (st == -1) {
        raler (1, "ce fichier n'existe pas!!! ");
    }

    if (! S_ISDIR (stats.st_mode))
        return 1;

    return 0;
}
