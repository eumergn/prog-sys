#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#define MYEOF -1
#define SIZE 1024

int mygetchar (void)
{
    static int size_buffer = 0;
    static unsigned char buffer [SIZE];
    static int indice_buffer = 0;

    if (indice_buffer >= size_buffer) {
        size_buffer = read (0, buffer, SIZE);

        if (size_buffer <= 0)
            return MYEOF;

        indice_buffer = 0;
    }

    return (unsigned char)buffer [indice_buffer++];
}
int main (void)
{
    int c;
    while ((c = mygetchar ()) != MYEOF)
        putchar (c);

    return 0;
}
