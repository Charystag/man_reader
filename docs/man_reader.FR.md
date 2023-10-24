# Man Reader - Un visualisateur en ligne de commande pour les pages de man

> :warning: Ce script necessite une version de bash >= pour s'executer.
> Vous pouvez verifier votre version avec `bash --version`

## Qu'est-ce que ce script fait ?

### Introduction

Ce script permet a son utilisateur de naviger a travers les pages de man
d'une maniere plus agreable. Il parse le man pour recuperer les sections
et les subsections puis affiche la table des matiere qui ressemble a la
suivante.
(L'exemple est tire de la page affichee par la commande `man man.1`, qui peut
aussi se lancer avec `man 1 man`)

![table des matieres de man 1 man](/assets/man1_toc.png "man 1 man")

### Actions de base

Apres avoir affiche la table des matieres, le script demande a l'utilisateur de
rentrer une action.
Les actions suivantes sont disponibles pour l'utilisateur :
- `nombre` : Un nombre entre 1 et le nombre de sections (18 sur notre exemple). \
Entrer une section invalide quitte l'affichage de la page de man
- `n` : Affiche la section suivante de la page de man. Presser `n` au debut de \
l'affichage va afficher la premiere section tandis que presser `n` a la fin de \
l'affichage va quitter l'affichage de la page en cours et demander a l'utilisateur \
une autre page de man a afficher
- `p` : Afficher la section precedente de la page de man
- `k` : Appelle la commande `clear` pour effacer l'output du terminal
- `s` : Affiche les sections de la page de man
- `q` : Quitte l'affichage de la page de man

### Affichage des sections

Essayons, par exemple, d'afficher le nombre `8`. Nous obtenons cet affichage dans le terminal :

![man.1 section 7.1](/assets/man1-8.png "section 7.1 of man in section 1")

> :warning: Attention, au moment de l'ecriture de cette documentation, le script ne fait pas
> la distinction entre l'affichage des sections et des sous-sections. Cela signifie que si nous
> decidons d'afficher la section 7 (numero 7 sur notre exemple), le script va afficher du numero
> 7 au numero 8, soit la partie de la section 7 qui se situe avant la premiere sous-section

Par exemple, si nous essayons d'afficher le numero `7` a la place du numero `8`, nous obtenons
l'affichage suivant :

![man.1 section 7](/assets/man1-7.png "section 7 of man in section 1")

## Comment utiliser ce script ?
