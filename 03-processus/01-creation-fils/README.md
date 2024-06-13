# Programmation système - Créer d'un processus fils et afficher des identifiants de processus

Complétez le programme `creer-fils.c` qui crée un processus.
Le programme n'admet pas d'argument.

Le processus fils doit afficher son identifiant de processus (pid) ainsi que celui de son père puis se terminer avec un code de retour égal au dernier chiffre de son pid.

Le processus père devra attendre la terminaison du fils, puis afficher l'identifiant de processus du fils ainsi que le code de retour du fils.

**Objectifs :** savoir créer un processus et attendre sa terminaison.

## Marche à suivre

La création d'un processus fils à partir du processus courant se fait via la primitive :

    int fork ()

On rappelle que cette primitive doit obligatoirement s'utiliser dans une structure `switch ()` :

    switch (fork ()) {
    case -1: /* erreur */
    case  0: /* processus fils */
    default: /* processus père */
    }

La récupération des identifiants de processus se fait via les primitives :

    pid_t getpid ()   // identifiant du processus courant
    pid_t getppid ()  // identififant du processus parent au processus courant 

On rappelle que pour afficher des types POSIX (e.g. `pid_t`) il faut les convertir en `ìntmax_t` (si signé) ou `uintmax_t` (si non signé) et utiliser respectivement `%jd` ou `%ju` pour le format avec la fonction `printf`.

Le fils doit attendre 1 seconde (via un appel à la fonction `sleep`) avant de se terminer avec la fonction :

    void exit (int status)

Le processus père doit attendre la fin du processus fils via la primitive :

    int wait (int *status)

puis afficher l'identifiant de processus du fils et sa valeur de retour.
Ces informations sont récupérables via les macros suivantes à utiliser sur l'entier passé en argument à la primitive `wait` :

    WIFEXITED ()
    WEXITSTATUS ()

## Test préliminaire

Exécutez votre programme et vérifiez les informations affichées.
Par exemple :

    ./creer-fils
    4714 4712
    4714 4

indique que l'identifiant de processus du fils est `4714` et que celui du père est `4712` (informations affichées par le processus fils).
Le processus père confirme que l'identifiant de processus du fils est `4714` et que le code de retour du processus fils est `4` ce qui correspond bien au chiffre des unités de l'identifiant du processus fils (informations affichées par le processus père).

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
