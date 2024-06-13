#include <stdarg.h>
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

#define SIZE 2

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

void concatener (char *result, int size, char *format, ...)
{
    va_list ap;
    va_start (ap, format);

    int n = vsnprintf (result, size, format, ap);
    if (n < 0 || n >= size)
        raler (0, "snprintf %s", result);

    va_end (ap);

    
    return;
}

int main (int argc, char *argv [])
{
    if (argc < 3) {
        raler (1, "Erreur, nombre d'arguments...\n");
    }
    int n = atoi (argv [1]);
    if (n < 1 || n == 10) {
        raler (1, "Erreur, nombre de n...\n");
    }
    int status;
    int i;
    char *args [argc + 2];
    for (i = 0; i < argc - 2; i++) {
        args [i] = argv [i + 2];
    }
    char string_num [SIZE];
    for (int j = 0; j < n; j++) {
        switch (fork ()) {
        case -1:
            raler (1, "Fork error...\n");
        case 0:
            concatener (string_num, SIZE, "%d", j);
            args [argc - 2] = string_num;
            args [argc - 1] = NULL;
            execvp (argv [2], args);
            raler (1, "Erreur, execvp...");
        default:
            CHK (wait (&status));
            if (WIFEXITED (status)) {
                if (WEXITSTATUS (status) != 0) {
                    raler (1, "Erreur, status...");
                }
            }
        }
    }
    return 0;
}
