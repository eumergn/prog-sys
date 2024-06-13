#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/types.h>
#include <unistd.h>
#define SIZE 100

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
displayContent1(char *filename){
    int fd = open (filename, O_RDONLY);
    CHK (fd);

    ssize_t bytes_read;
    char buffer[SIZE];
    while((bytes_read=read(fd,buffer,SIZE))>0){
        printf("%d: ", bytes_read);
	//for (size_t i = 0; i < bytes_read;i++) printf("%s", buffer[i]);
    }



    CHK(close(fd)       );
}

int main (int argc, char *argv [])
{
    if(argc != 2) raler(1,"Nombre d'arguments non respectes!!!");

    char *filename = argv[1];

    displayContent1(filename);

    return 0;
}






































// if (argc != 2) {
    //     raler (0, "NB D'ARGUMENTS!!! ");
    // }

    // char *fichier = argv [1];
    // int fd1 = open (fichier, O_RDONLY);
    // CHK (fd1);

    // char buffer [SIZE];
    // ssize_t size_write;

    // while ((size_write = read (fd1, buffer, SIZE)) > 0) {
    //     ssize_t size_read = 0;
    //     while (size_write > size_read) {
    //         ssize_t check = write (STDOUT_FILENO, buffer + size_read, size_write - size_read);

    //         if (check == -1) {
    //             raler (EXIT_FAILURE, "Erreur d'ecriture!!! ");
    //         }
    //         size_read += check;
    //     }
    // }
    // CHK (size_write);
    // CHK (close (fd1));