#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <unistd.h>
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
        raler (0, "NB D'ARGUMENTS!!! ");
    }
    const char *nom_fichier = argv [1];

    char buffer [SIZE];
    int fd1 = open (nom_fichier, O_RDONLY);
    if (fd1 == -1) {
        raler (1, "Erreur d'ouverture!!! ");
    }

    int cmp_ligne = 0;
    int cmp_mot = 0;
    int cmp_char = 0;
    int dans_mot = 0;

    ssize_t bytes_read;

    while ((bytes_read = read (fd1, buffer, sizeof (buffer))) > 0) {
        for (ssize_t i = 0; i < bytes_read; i++) {
            cmp_char++;
            if (buffer [i] == '\n') {
                cmp_ligne++;
            }
            if (buffer [i] == '\v' || buffer [i] == '\n' ||
                buffer [i] == '\t' || buffer [i] == '\f' ||
                buffer [i] == '\r' || buffer [i] == ' ') {
                dans_mot = 0;
            } else if (! dans_mot) {
                dans_mot = 1;
                cmp_mot++;
            }
        }
    }

    if (bytes_read == -1) {
        raler (1, "Erreur de lecture!!! ");
    }
    CHK (close (fd1));

    printf ("%d %d %d\n", cmp_ligne, cmp_mot, cmp_char);
}
