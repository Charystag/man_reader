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
une autre page de man a 1'
