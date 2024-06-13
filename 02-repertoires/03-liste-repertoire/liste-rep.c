#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/stat.h>
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

void arborescence (const char *repertoire, int current_depth, int depth_max)
{
    if (current_depth > depth_max)
        return;

    DIR *dp = opendir (repertoire);
    if (dp == NULL) {
        raler (1, "Erreur ouverture DIR!!! ");
    }
    printf ("%s\n", repertoire);

    struct dirent *ep;
    while ((ep = readdir (dp)) != NULL) {
        if ((strcmp (ep->d_name, ".") && strcmp (ep->d_name, ".."))) {
            char final_result [PATH_MAX];
            concatener (final_result, PATH_MAX, "%s/%s", repertoire,
                        ep->d_name);
            struct stat stats;
            int st = lstat (final_result, &stats);
            if (st == -1) {
                raler (1, " Erreur de fichier ou lien... ");
            }
            if (S_ISDIR (stats.st_mode)) {
                arborescence (final_result, current_depth++, depth_max);
            }
        }
    }
    closedir (dp);
}

int main (int argc, char *argv [])
{
    if (argc < 3) {
        raler (0, "NB D'ARGUMENTS!!! ");
    }

    int current_depth = 0;
    const char *repertoire = argv [1];
    int depth_max = atoi (argv [2]);

    if (depth_max < 1 || depth_max > 9) {
        raler (1, "Erreur , le profondeur ne correspond pas!!! ~ 1>depth>9 ~ ");
    }
    arborescence (repertoire, current_depth, depth_max);

    return 0;
}