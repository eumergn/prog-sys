#include <errno.h>
#include <fcntl.h>
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

/*
    argv[] -> le nombre de noms quon ecrit
*/

int main (int argc, char *argv [])
{
    if (argc != 2) {
        raler (0, "BCP D'ARGUMENTS!!!");
    }
    int fd1 = open (argv [1], O_RDONLY);
    printf ("%s: ", argv [1]);
    if (fd1 == -1) {
        if (errno == EACCES) {
            printf ("-");
        } else {
            raler (1, "Erreur systeme");
        }
    } else {
        printf ("R");
        CHK (close (fd1));
    }

    int fd2 = open (argv [1], O_WRONLY);
    if (fd2 == -1) {
        if (errno == EACCES) {
            printf ("-\n");
        } else {
            raler (1, "Erreur systeme");
        }
    } else {
        printf ("W\n");
        CHK (close (fd2));
    }
}