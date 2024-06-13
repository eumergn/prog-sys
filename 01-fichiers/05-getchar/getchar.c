#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#define MYEOF -1

int mygetchar (void)
{
    unsigned char c;
    ssize_t bytes_read = read (0, &c, 1); // bc char is 1byte

    if (bytes_read == 1) {
        return (int)c;
    } else
        return MYEOF;
}

int main (void)
{
    int c;
    while ((c = mygetchar ()) != MYEOF)
        putchar (c);

    return 0;
}

// La conversion byte to int => (int)ch
