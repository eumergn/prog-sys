#include <errno.h>
#include <signal.h>
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

struct elem {
    int type;
    long long int val;
    struct elem *suiv;
};
struct elem *tete = NULL;

void inserer (int type, long long int val)
{
    struct elem *e;
    if ((e = malloc (sizeof *e)) == NULL)
        raler (1, "malloc");

    e->suiv = tete;
    e->type = type;
    e->val = val;
    tete = e;
}

int main (void)
{
}
