#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/wait.h>
#include <unistd.h>

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
        raler (1, "Erreur, nb d'arguments...\n");
    }

    int n = atoi (argv [1]);
    if (n <= 0) {
        raler (1, "Erreur, n<=0 ...\n");
    }

    int pipefd [2];
    if (pipe (pipefd) == -1) {
        raler (1, "Erreur, pipe... \n");
    }
    int k, num;
    ssize_t bytes_read, bytes_written;
    pid_t pid1, pid2;
    switch (pid1 = fork ()) {
    case -1:
        raler (1, "Erreur, fork()...\n");
    case 0:
        close (pipefd [0]);
        for (int i = 2; i <= n; i++) {
            if ((write (pipefd [1], &i, 4)) == -1) {
                raler (1, "Erreur, write()...\n");
            }
        }
        close (pipefd [1]);
        sleep (1);
        exit (EXIT_SUCCESS);
    default:
        while ((bytes_read = read (pipefd [0], &k, 4)) > 0) {
            if (k == -1) {
                printf ("%d\n", k);
                switch (pid2 = fork ()) {
                case -1:
                    raler (1, "Erreur, fork()...\n");
                case 0:
                    close (pipefd [1]);
                    while ((bytes_read = read (pipefd [1], &num, 4)) > 0) {
                        if (num % k != 0) {
                            bytes_written = write (pipefd [1], &num, 4);
                            if (bytes_written == -1) {
                                raler (1, "Erreur, write()...\n");
                            }
                        }
                    }
                    if (bytes_read == -1) {
                        raler (1, "Erreur, read()...\n");
                    }
                    close (pipefd [0]);
                    break;
                default:
                    close (pipefd [0]);
                    break;
                }
            }
        }
        if (bytes_read == -1) {
            raler (1, "Erreur, read()...\n");
        }
    }
}
