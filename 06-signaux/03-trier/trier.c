#include <errno.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <time.h>
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

void swap (int *x, int *y)
{
    int tmp = *x;
    *x = *y;
    *y = tmp;
}

void tri (int *tab, int size)
{
    for (int i = size - 1; i > 0; --i) {
        for (int j = 0; j < i; ++j) {
            if (tab [j + 1] < tab [j]) {
                swap (&tab [j], &tab [j + 1]);
            }
        }
    }
}
void handler_SIGALRM (int signum)
{
    (void)signum;
    printf ("working\n");
}

int main (int argc, char *argv [])
{
    if (argc != 2) {
        raler (1, "Erreur, nb d'arguments...\n");
    }
    int size = atoi (argv [1]);
    if (size < 0) {
        raler (1, "Erreur, la taille -1...\n");
    }

    srand ((unsigned int)time (NULL));

    // Création et initialisation du tableau avec des valeurs aléatoires
    int tableau [size];
    for (int i = 0; i < size; ++i) {
        tableau [i] = rand () % 1001;
    }

    // Mise en place de la gestion du signal SIGALRM
    struct sigaction sig_act;
    sig_act.sa_handler = handler_SIGALRM;
    sigemptyset (&sig_act.sa_mask);
    sig_act.sa_flags = 0;
    sigaction (SIGALRM, &sig_act, NULL);

    // printf("working\n");
    alarm (1);

    tri (tableau, size);

    alarm (0);

    // Afficher le contenu du tableau trié
    for (int i = 0; i < size; ++i) {
        printf ("%d\n", tableau [i]);
    }

    return EXIT_SUCCESS;
}
