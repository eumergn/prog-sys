# Programmation système - Afficher des nombres premiers

Complétez le programme `crible.c` qui affiche les nombres premiers inférieurs ou égaux à un nombre `N` donné en argument :

    ./crible N

Pour identifier ces nombres, on se propose de réaliser un criblage naïf à l'aide d'un pipeline de processus :

Les processus s'envoient des entiers via des tubes.
Le rôle de chaque type de processus est le suivant :
- le processus « Gén. » produit la liste des entiers consécutifs 2, 3, ..., N ;
- un processus « /k » élimine (c'est-à-dire ne transmet pas au processus suivant) les entiers qui sont multiples de *k* (sauf *k* lui-même, qui est transmis) ;
- le processus « Pr. » se charge d'afficher sur la sortie standard les entiers qu'il reçoit. 

Les entiers affichés en sortie du pipeline sont les nombres premiers inférieurs ou égaux à *N*.

**Objectifs :** savoir construire et utiliser un pipeline de processus.

## Marche à suivre

Il faut dans un premier temps créer le tube anonyme à l'aide de la primitive :

    int pipe (int fildes[2])

Ensuite il faut créer le processus fils « Gén. » via la primitive :

    int fork ()

On rappelle que cette primitive doit obligatoirement s'utiliser dans une structure switch () :

    switch (fork ()) {
    case -1: /* erreur */
    case  0: /* processus fils */
    default: /* processus père */
    }

Le processus « Gén. » doit envoyer dans le pipeline les nombres de 2 à *N*.

Il faut maintenant créer les processus « /k » dont le nombre dépend de *N*.
Pour chaque nouveau processus *k* il faut :
- créer un nouveau tube (pour communiquer avec le processus *k+1*)
- créer le processus *k*
- gérer les descripteurs actuellement ouverts (tube avec le processus *k-1*, tube avec le futur processus *k+1*)

Puis il faut créer le processus « Pr. » qui se charge d'afficher sur la sortie standard les nombres reçus en fin du pipeline.

Enfin, le processus principal devra attendre la terminaison de tous ses processus fils et se terminer avec un code de retour nul si tous les processus fils se sont terminés sans erreur, ou non nul dans le cas contraire.

Chaque processus fils devra attendre 1 seconde via la fonction `sleep ()` puis lire sur le côté lecture du tube et écrire les données lues sur sa sortie standard.
Le processus père doit lire des données depuis son entrée standard et écrire les données lues sur le côté écriture du tube.

Rappel : n'oubliez pas de fermer les descripteurs inutiles dès que possible.

## Test préliminaire

Vous pouvez tester votre programme via la commande suivante qui copie le contenu du fichier `/bin/ls` dans le fichier `toto` à l'aide de votre programme :

    ./tube < /bin/ls > toto

La commande `cmp` compare le contenu des deux fichiers `/bin/ls` et `toto`.
Si elle ne produit rien en sortie, c'est que le contenu des deux fichiers est identique et que votre programme est, a priori, fonctionnel :

    cmp /bin/ls toto

## Validation

Votre programme doit obligatoirement passer tous les tests sur gitlab (il suffit de `commit/push` le fichier source pour déclencher le pipeline de compilation et de tests) avant de passer à l'exercice suivant.
