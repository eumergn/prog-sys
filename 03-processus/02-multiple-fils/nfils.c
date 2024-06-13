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

int main (int argc, char *argv [])
{
    if (argc != 2) {
        raler (1, "Erreur , nombre d'argument...");
    }
    int n = atoi (argv [1]);
    if (n < 1 || n > 9) {
        raler (1, "n inf 1 or sup 9...");
    }
    int status;
    pid_t child;
    for (int i = 0; i < n; i++) {
        switch (child = fork ()) {
        case -1:
            raler (1, "Erreur, fork()..");
        case 0:
            sleep (1);
            exit (0);
        default:
            // break;
            continue;
        }
    }

    while (n > 0) {
        pid_t code_retour = wait (&status);
        if (WIFEXITED (status)) {
            printf ("%jd %d\n", (intmax_t)code_retour, WEXITSTATUS (status));
        }
        n--;
    }
    return 0;
}
