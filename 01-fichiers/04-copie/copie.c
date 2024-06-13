#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/types.h>
#include <unistd.h>
#define SIZE 8192

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
    if (argc != 3) {
        raler (0, "NB D'ARGUMENTS!!! ");
    }
    char *source_name = argv [1];
    char *destination_name = argv [2];

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

    while ((bytes_read = read (fd_source, buffer, sizeof (buffer))) > 0) {
        bytes_written = write (fd_destination, buffer, bytes_read);
        if (bytes_written == -1) {
            raler (1, "Erreur d'ecriture du fichier destination!!! ");
        }
    }
    close (bytes_read);
    close (bytes_written);
    CHK (close (fd_source));
    CHK (close (fd_destination));

    return 0;
}
