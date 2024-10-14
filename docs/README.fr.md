# Man Reader - Un visualisateur en ligne de commande pour les pages de man

> :warning: Ce script nécessite une version de bash >= pour s'éxecuter.
> Vous pouvez vérifier votre version avec `bash --version`

## Preambule - Comment naviguer à travers le man ?

Vous devez déjà savoir que l'on peut scroller avec les souris et utiliser
les flèches directionnelles pour naviguer a travers le man. Cependant, cet
outil etant conçu pour etre utilisé en ligne de commande, il existe des
touches qui nous permettent de le traverser plus vite :
- `j` : La touche `j` nous fait avancer d'une ligne. On peut ajouter un \
nombre avant `j` pour avancer de `n` lignes. Par exemple, `6j` nous fait \
avancer de six lignes.
- `k` : La touche `k` nous fait reculer d'une ligne. On peut aussi ajouter
un nombre avant la touche `k`
- `g` : La touche `g` nous ammène en haut de la page
- `G` : La touche `G` (Maj + g) nous ammène en bas de la page
- `f` : La touche `f` nous fait avancer d'un écran. Nous pouvons aussi \
presser la barre espace pour obtenir le même résultat.
- `b` : La touche `b` nous fait reculer d'un écran
- `d` : La touche `d` nous fait avancer d'un demi-écran
- `u` : La touche `u` nous fait reculer d'un demi-écran
- `q` : La touche `q` nous permet de quitter la page de man

## Qu'est-ce que ce script fait ?

### Introduction

Ce script permet à son utilisateur de naviger à travers les pages de man
d'une maniere plus agréable. Il parse le man pour récuperer les sections
et les subsections puis affiche la table des matières qui ressemble à la
suivante.
(L'exemple est tire de la page affichée par la commande `man printf.3`, qui peut
aussi se lancer avec `man 3 printf`)

![table des matières de man 3 printf](/assets/printf3_toc.png "man 3 printf")

### Actions de base

Apres avoir affiche la table des matières, le script demande à l'utilisateur de
rentrer une action.
Les actions suivantes sont disponibles pour l'utilisateur :
- `nombre` : Un nombre entre 1 et le nombre de sections (18 sur notre exemple). \
Entrer une section invalide quitte l'affichage de la page de man
- `n` : Affiche la section suivante de la page de man. Presser `n` au debut de \
l'affichage va afficher la première section tandis que presser `n` à la fin de \
l'affichage va quitter l'affichage de la page en cours et demander à l'utilisateur \
une autre page de man à afficher
- `p` : Afficher la section precedente de la page de man
- `k` : Appelle la commande `clear` pour effacer l'output du terminal
- `s` : Affiche les sections de la page de man
- `q` : Quitte l'affichage de la page de man

### Affichage des sections

Essayons, par exemple, d'afficher le nombre `8`. Nous obtenons cet affichage dans le terminal :

![printf.3 section 3.1](/assets/printf3-4.png "section 3.1 of printf in section 3")

> :bulb: Lors de l'affichage d'une page, vous pouvez presser `k` pour ajouter des espaces en
> bas de la page. Ceci nous donne l'affichage suivant si nous essayons par exemple d'afficher le numero `1`: 

![printf.3 section 1 padded](/assets/printf3-1_padded.png "section 1 of printf in section 3 with padding")

> :warning: Attention, au moment de l'écriture de cette documentation, le script ne fait pas
> la distinction entre l'affichage des sections et des sous-sections. Cela signifie que si nous
> decidons d'afficher la section 3 (numero 3 sur notre exemple), le script va afficher du numero
> 3 au numero 4, soit la partie de la section 3 qui se situe avant la première sous-section

Par exemple, si nous essayons d'afficher le numero `3` à la place du numero `4`, nous obtenons
l'affichage suivant :

![printf.3 section 3](/assets/printf3-3.png "section 3 of printf in section 3")

## Comment utiliser ce script ?

### Lancement du script à partir de Github

Pour éxecuter ce script, vous pouvez lancer la commande suivante dans votre terminal :

```bash
bash <(curl --connect-timeout 10 -fsSL https://raw.githubusercontent.com/Charystag/man_reader/master/man_reader.sh)
```

<blockquote>

:bulb: Vous pouvez lancer
```bash
bash <(curl --connect-timeout 10 -fsSL https://raw.githubusercontent.com/Charystag/man_reader/master/man_reader.sh) bash 'Process Substitution'
```
Pour plus d'information sur la **Process Substitution**

</blockquote>

Cela va afficher le menu principal et le script pourra etre éxecuté comme specifie au-dessus.

En executant le script de cette maniere, les arguments peuvent etre specifies en ligne de commande
comme avec la commande `./man_reader.sh`

### Installation locale

Pour installer le script localement, dans `$HOME/.local/bin/man_reader`, vous pouvez lancer :
```bash
bash <(curl --connect-timeout 10 -fsSL https://raw.githubusercontent.com/Charystag/man_reader/master/man_reader.sh) -i
```
Par la suite, en ajoutant le chemin `$HOME/.local/bin/man_reader` à la variable PATH, vous pourrez lancer le script avec :
```bash
man_reader
```

> :bulb: Vous pouvez ajouter la ligne `export PATH="$PATH:$HOME/.local/bin/"` dans le fichier
> `~/.zshrc` ou `~/.bashrc` si zsh ou bash est votre login shell.

### Affichage de la table des matières

Pour afficher seulement la table des matières de la page de man, vous pouvez lancer :
```bash
bash <(curl --connect-timeout 10 -fsSL https://raw.githubusercontent.com/Charystag/man_reader/master/man_reader.sh) -l [page]
```
Avec une page en argument optionnel. Si aucune page n'est entree, une page sera demandée en entrée au demarrage du script.
La table des matières de la page s'affichera et le script se terminera

### Lecture d'une seule page (pas de menu principal)

En lancant la commande suivante :
```bash
bash <(curl --connect-timeout 10 -fsSL https://raw.githubusercontent.com/Charystag/man_reader/master/man_reader.sh) page [section]
```
Il est  possible d'afficher la page demandée (qui peut etre passee en argument en utilisant le format page.man\_section)
- Si aucune section (optionnelle) n'est donnée, le script ouvrira le menu principal pour la page de man et quitter quand l'utilisateur le demande
- Si une section est donnée en argument, le script affichera la section pour la page de man demandée.
Les sections peuvent etre specifiées dans deux formats :
	- Un nombre (entre 1 et le nombre de sections de la table des matières) (ex : `man_reader bash 30`)
	- Une chaine qui decrit la section (ex : `man_reader bash 'Process Substitution`). N'oubliez pas les `'` ou `"` pour que la section soit traitée comme un seul argument

### Obtenir de l'aide

Executez la commande suivante :
```bash
bash <(curl --connect-timeout 10 -fsSL https://raw.githubusercontent.com/Charystag/man_reader/master/man_reader.sh) -h
```
Pour obtenir de l'aide sur l'utilisation du script

## Contribuer

Il y à deux manieres de contribuer à ce projet
- M'envoyer un message sur Discord ou Slack (pour les etudiants de 42) ou à ce [mail](mailto:nsainton@student.42.fr?subject=[man_reader])
- Les Pull-Request qui sont, pour le moment fermées mais seront bientot disponible pour vous permettre d'ajouter toutes vos incroyables features au projet

## Démonstration en vidéo

Cliquez sur la photo pour ouvrir la vidéo sur youtube

[![preview](/assets/thumbnail.png)](https://youtu.be/vxxwOgG8tA4)
