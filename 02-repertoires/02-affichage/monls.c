#include <dirent.h>
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>

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
    if (argc != 2) {
        raler (0, "NB D'ARGUMENTS!!! ");
    }

    DIR *dp = opendir (argv [1]);
    if (dp == NULL)
        raler (1, "Erreur d'ouverture!!! ");

    struct dirent *d;
    while ((d = readdir (dp)) != NULL) {
        if ((strcmp (d->d_name, ".") && strcmp (d->d_name, ".."))) {
            printf ("%s\n", d->d_name);
        }
    }
    if (errno != 0) {
        raler (-1, "Erreur lecture repertoire!!! ");
    }
    CHK (closedir (dp));
    return 0;
}