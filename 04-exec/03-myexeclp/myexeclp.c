#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <unistd.h>

#define MAX_ARG 5
#define INCREMENT_REALLOC 10

/** fonction qui sépare la chaine de caractères 'chaine'
 *  avec tous les séparateurs présents dans 'separateurs'
 *  renvoie un tableau NULL-terminated de mots
 *  utilise la mémoire de chaine pour cela (modifie la chaine) !
 */
char **separe (char *chaine, const char *separateurs)
{
    char **tab;
    int i, s, m, size = INCREMENT_REALLOC;

    tab = malloc (size * sizeof (char *));
    if (tab == NULL)
        return NULL;
    m = 0;
    i = 0;
    while (chaine [i] != 0) {
        // saute un séparateur
        for (s = 0; separateurs [s] != '\0'; s++)
            if (chaine [i] == separateurs [s])
                break;
        if (separateurs [s] != '\0') {
            // met une fin de chaine à la place du séparateur et avance
            chaine [i++] = '\0';
            continue; // les séparateurs n'ont pas été épuisés
        }

        if (chaine [i] != 0)
            tab [m++] = chaine + i;
        if (m == size) {
            // si j'atteins la limite de mon tableau, je l'agrandis.
            size += INCREMENT_REALLOC;
            tab = realloc (tab, size * sizeof (char *));
            if (tab == NULL)
                return NULL;
        }
        // saute les caractères non séparateurs
        for (; chaine [i] != '\0'; i++) {
            for (s = 0; separateurs [s] != '\0'; s++)
                if (chaine [i] == separateurs [s])
                    break;
            if (separateurs [s] != '\0')
                break; // trouvé un caractère séparateur : passer au suivant
        }
    }
    tab [m] = NULL;
    return tab;
}

int myexeclp (const char *file, const char *arg, ...)
{
    char *env_val = getenv ("PATH");
    if (env_val == NULL) {
        perror ("getenv non trouve...\n");
        return -1;
    }

    char *copie = strdup (env_val);
    // printf("2:\t%s\n",copie);
    char **paths = separe (copie, ":");
    if (! paths) {
        perror ("getenv non trouve...\n");
        return -1;
    }
    // printf("\t%s\n",*paths);

    char pathTotal [_PC_PATH_MAX];
    int ilyest = 0;

    DIR *dp;
    struct dirent *d;
    for (int i = 0; paths [i] != NULL && ! ilyest; i++) {
        dp = opendir (paths [i]);
        if (dp != NULL) {
            while ((d = readdir (dp)) != NULL) {
                if (strcmp (d->d_name, file) == 0) {
                    snprintf (pathTotal, sizeof (pathTotal), "%s/%s", paths [i],
                              file);
                    ilyest = 1;
                    break;
                }
            }
            closedir (dp);
        } else {
            perror ("Erreur,ouverture repertoire...\n");
            return -1;
        }
    }
    free (copie);
    free (paths);

    if (! ilyest) {
        errno = ENOENT;
        return -1;
    }

    char *argv [MAX_ARG + 3];
    va_list ap;
    va_start (ap, arg);
    argv [0] = (char *)arg;
    int acc = 1;
    while (acc <= MAX_ARG + 2) {
        argv [acc] = va_arg (ap, char *);
        if (argv [acc] == NULL)
            break;
        acc++;
    }
    va_end (ap);

    if (acc > MAX_ARG) {
        errno = E2BIG;
        return -1;
    }

    execve (pathTotal, argv, __environ);
    perror ("Erreur,execve...\n");
    return -1;
}

int main (int argc, char *argv [])
{
    if (argc < 2) {
        fprintf (stderr, "usage: %s fichier ...\n", argv [0]);
        exit (EXIT_FAILURE);
    }

    switch (argc) {
    case 2:
        myexeclp (argv [1], argv [1], NULL);
        break;

    case 3:
        myexeclp (argv [1], argv [1], argv [2], NULL);
        break;

    case 4:
        myexeclp (argv [1], argv [1], argv [2], argv [3], NULL);
        break;

    case 5:
        myexeclp (argv [1], argv [1], argv [2], argv [3], argv [4], NULL);
        break;

    case 6:
        myexeclp (argv [1], argv [1], argv [2], argv [3], argv [4], argv [5],
                  NULL);
        break;

    case 7:
        myexeclp (argv [1], argv [1], argv [2], argv [3], argv [4], argv [5],
                  argv [6], NULL);
        break;

    case 8:
        myexeclp (argv [1], argv [1], argv [2], argv [3], argv [4], argv [5],
                  argv [6], argv [7], NULL);
        break;
    }

    perror ("myexeclp");
    return EXIT_FAILURE;
}