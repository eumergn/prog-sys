# Programmation système - Tester la présence d'un utilisateur

Complétez le programme `presence.c` qui vérifie si un utilisateur est connecté.
Le programme admet en argument le nom d'utilisateur (limité à 32 caractères) :

    ./presence username

Le programme doit être équivalent au script shell :

    ps eaux > toto ; grep "^$1 " < toto > /dev/null && echo "$1 is connected"

En outre, le programme principal va :
- créer un processus fils qui doit réaliser l'exécution de la commande `ps` avec la fonction `execlp`. La sortie standard de ce processus doit être redirigée dans le fichier `toto` (à créer) ;
- créer un processus fils qui doit réaliser l'exécution de la commande `grep` avec la fonction `execlp`. L'entrée et la sortie standard de ce processus doivent respectivement être redirigées vers les fichier `toto` et `/dev/null`. 
- afficher, en cas de succès du second processus fils, la chaîne : `username is connected`

**Objectifs :** savoir rediriger l'entrée et la sortie standard d'un processus

## Marche à suivre

Il faut dans un premier temps créer le premier processus fils via la primitive :

    int fork ()

On rappelle que cette primitive doit obligatoirement s'utiliser dans une structure switch () :

    switch (fork ()) {
    case -1: /* erreur */
    case  0: /* processus fils */
    default: /* processus père */
    }

Le processus fils doit créer le fichier `toto` et l'ouvrir en écriture seule à l'aide de la primitive :

    int open (const char *path, int oflag, ...)

Puis il doit rediriger sa sortie standard vers le fichier `toto` à l'aide de la primitive :

    int dup2 (int fildes, int fildes2)

Enfin, ce processus fils doit exécuter la commande `ps` avec l'argument `eaux` via la fonction :

    int execlp (const char *file, const char *arg0, ...)

Le processus père doit vérifier la bonne exécution du processus fils via la primitive et les macros :

    int wait (int *status)
    WIFEXITED ()
    WEXITSTATUS ()

Ensuite, il doit créer le motif `"^username "` (qui signifie : « toutes les lignes qui débutent par `username` ») où `username` est le nom d'utiliseur passé en argument du programme.
Pour ce faire, vous pouvez utiliser la fonction `concatener ()` fournie  dans le fichier `presence.c`.
On rappelle que les noms d'utilisateurs ne peuvent pas dépasser 32 caractères (d'après le manuel de la commande `useradd`).

Puis le processus père peut créer le second processus fils et attendre sa terminaison.
Si le processus fils termine avec un code nul, le motif a été trouvé et l'utilisateur est connecté auquel cas il faut afficher sur la sortie standard la chaîne :

    username is connected

où `username` est le nom d'utilisateur passé en argument du programme.
Vous pouvez utiliser une fonction de bibliothèque pour cet affichage (e.g. `printf`).
Sinon, le programme doit se terminer avec un code non nul.

Le second processus fils doit ouvrir le fichier `toto` en lecture seule et rediriger son entrée standard vers ce dernier.
Il doit également ouvrir le fichier `/dev/null` et rediriger sa sortie standard vers ce dernier.
Pour ce faire, il faut utiliser les primitives :

    int open (const char *path, int oflag, ...)
    int dup2 (int fildes, int fildes2)

Enfin, le second processus fils doit exécuter la commande `grep` avec le motif créé précédemment via la fonction :

    int execlp (const char *file, const char *arg0, ...)

Rappel : n'oubliez pas de fermer les descripteurs devenus inutiles.

## Test préliminaire

La commande suivante devrait afficher 1 (l'utilisateur `unknown_user` n'a pas été trouvé) :

    ./presence unknown_user ; echo $?

alors que la commande suivante devrait afficher : `root is connected`

    ./presence root

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
