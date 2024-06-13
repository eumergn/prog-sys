#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>

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

volatile sig_atomic_t compteur = 1;
void handler (int signum)
{
    (void)signum;

    printf ("compteur: %d\n", compteur);
    compteur++;
}

int main (void)
{
    struct sigaction s;
    s.sa_handler = handler;
    s.sa_flags = 0;

    CHK (sigemptyset (&s.sa_mask));
    CHK (sigaction (SIGINT, &s, NULL));

    while (compteur <= 5) {
        ;
    }
    return EXIT_SUCCESS;
}
