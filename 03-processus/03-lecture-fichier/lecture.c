#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/wait.h>
#include <unistd.h>

#define SIZE 1

#define CHK(op)                                                                \
    do {                                                                       \
        if ((op) == -1) {                                                      \
            perror (#op);                                                      \
            exit (1);                                                          \
        }                                                                      \
    } while (0)

#ifdef COLOR
#define JAUN "\x1B[33m"
#define BLEU "\x1B[34m"
#else
#define JAUN ""
#define BLEU ""
#endif

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

void lecture_fichier (char *nom_fichier)
{
    int fd = open (nom_fichier, O_RDONLY);
    CHK (fd);

    int status;
    char buffer [SIZE];
    switch (fork ()) {
    case -1:
        raler (1, "Erreur,fork()...");
    case 0:
        while (read (fd, buffer, SIZE) > 0) {
            printf (BLEU "%s", buffer);
        }
        exit (0);

    default:
        while (read (fd, buffer, SIZE) > 0) {
            printf (JAUN "%s", buffer);
        }
        CHK (wait (&status));
        if (WIFEXITED (status)) {
            CHK (WEXITSTATUS (status));
        }
    }
    CHK (close (fd));
}

int main (int argc, char *argv [])
{
    if (argc != 2) {
        raler (0, "NB D'ARGUMENTS!!!");
    }
    char *nom_fichier = argv [1];
    lecture_fichier (nom_fichier);

    return 0;
}
