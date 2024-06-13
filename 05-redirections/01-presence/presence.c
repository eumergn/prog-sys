#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAX_SIZE 32

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
// 0 : Entree standard
// 1 : Sortie standard
// 2 : Sortie d'erreur
int main (int argc, char *argv [])
{
    if (argc != 2) {
        raler (1, "Erreur, nb d'arguments...\n");
    }
    char *username = argv [1];
    if (strlen (username) > MAX_SIZE + 1) {
        raler (1, "Erreur, nom d'utilisateur trop grand...\n");
    }
    int fd = 0;
    int fdtoto = 0;
    int fdnull = 0;
    int status;
    pid_t pid1, pid2;
    switch (pid1 = fork ()) {
    case -1:
        raler (1, "Erreur, fork()...\n");
    case 0:
        fd = open ("toto", O_WRONLY | O_CREAT | O_TRUNC, 0666);
        CHK (fd);

        if (dup2 (fd, 1) == -1) {
            raler (1, "Erreur, duplication...\n");
        }
        CHK (close (fd));

        execlp ("ps", "ps", "eaux", NULL);
        raler (1, "Erreur, execlp()...\n");
    default:
        CHK (wait (&status));
        if (! WIFEXITED (status) || WEXITSTATUS (status) != 0) {
            raler (1, "Erreur,wait()...\n");
        }

        char user [MAX_SIZE];
        snprintf (user, MAX_SIZE + 3, "^%s ", username);

        switch (pid2 = fork ()) {
        case -1:
            raler (1, "Erreur, fork()...\n");
        case 0:
            fdtoto = open ("toto", O_RDONLY);
            CHK (fd);

            fdnull = open ("/dev/null", O_WRONLY);
            CHK (fdnull);

            if (dup2 (fdtoto, 0) == -1 || dup2 (fdnull, 1) == -1) {
                raler (1, "Erreur, duplication...\n");
            }
            CHK (close (fdtoto));
            CHK (close (fdnull));

            execlp ("grep", "grep", user, NULL);
            raler (1, "Erreur, execlp(grep)...\n");
        default:
            CHK (wait (&status));
            if (WIFEXITED (status) && WEXITSTATUS (status) == 0) {
                printf ("%s is connected\n", username);
            } else {
                raler (1, "Erreur,wait()...\n");
            }
        }
    }
    return 0;
}
