#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/wait.h>
#include <unistd.h>

#define SIZE 256

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

void copier (int fdsrc, int fddst)
{
    char buffer [SIZE];
    ssize_t bytes_read, bytes_written;

    while ((bytes_read = read (fdsrc, buffer, SIZE)) > 0) {
        bytes_written = write (fddst, buffer, bytes_read);
        if (bytes_written != bytes_read) {
            raler (1, "Erreur, write()...\n");
        }
    }
    if (bytes_read == -1) {
        raler (1, "Erreur,read()...\n");
    }
}

int main (void)
{
    int pipefd [2];
    if (pipe (pipefd) == -1) {
        raler (1, "Erreur, pipe()...\n");
    }

    int status;
    pid_t pid;
    switch (pid = fork ()) {
    case -1:
        raler (1, "Erreur,fork()...\n");
    case 0:
        close (pipefd [1]);
        copier (pipefd [0], 1);
        close (pipefd [0]);
        sleep (3);
        break;
    default:
        copier (0, pipefd [1]);
        close (pipefd [1]);

        CHK (wait (&status));
        if (WIFEXITED (status) && WEXITSTATUS (status) != 0) {
            raler (1, "Erreur,wait()...\n");
        }
    }
}
