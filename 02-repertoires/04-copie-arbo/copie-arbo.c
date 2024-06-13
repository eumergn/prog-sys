#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#define SIZE 4096

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
void copie_fichier (char *source_name, char *destination_name)
{
    int fd_source = open (source_name, O_RDONLY);
    if (fd_source == -1) {
        raler (1, "Erreur d'ouverture du fichier source!!! ");
    }

    int fd_destination =
        open (destination_name, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (fd_destination == -1) {
        raler (1, "Erreur d'ouverture du fichier destination!!! ");
    }

    char buffer [SIZE];
    ssize_t bytes_read, bytes_written;

    while ((bytes_read = read (fd_source, buffer, SIZE)) > 0) {
        bytes_written = write (fd_destination, buffer, bytes_read);
        if (bytes_written == -1) {
            raler (1, "Erreur d'ecriture du fichier destination!!! ");
        }
    }
    CHK (close (fd_source));
    CHK (close (fd_destination));
}

void copie_dir (const char *source_rep, const char *destination_rep)
{
    DIR *dp = opendir (source_rep);
    if (dp == NULL) {
        raler (1, "Erreur ouverture DIR!!! ");
    }
    char source_path [PATH_MAX];
    char dest_path [PATH_MAX];

    int creation_mkdir;
    CHK (creation_mkdir = mkdir (destination_rep, 0777));
    struct dirent *ep;
    while ((ep = readdir (dp)) != NULL) {
        if (strcmp (ep->d_name, ".") != 0 && strcmp (ep->d_name, "..") != 0) {
            concatener (source_path, PATH_MAX, "%s/%s", source_rep, ep->d_name);
            concatener (dest_path, PATH_MAX, "%s/%s", destination_rep,
                        ep->d_name);
            struct stat stats;
            int st;
            CHK (st = lstat (source_path, &stats));
            if (S_ISDIR (stats.st_mode)) {
                copie_dir (source_path, dest_path);
            } else if (S_ISREG (stats.st_mode)) {
                copie_fichier (source_path, dest_path);
            } else {
                raler (1, "Ce n'est ni un fichier ni un dossier...");
            }
        }
    }

    CHK (closedir (dp));
}

int main (int argc, char *argv [])
{
    if (argc != 3) {
        raler (0, "NB D'ARGUMENTS!!! ");
    }

    char *source_rep = argv [1];
    char *destination_rep = argv [2];
    copie_dir (source_rep, destination_rep);

    return 0;
}
