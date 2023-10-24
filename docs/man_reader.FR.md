# Man Reader - Un visualisateur en ligne de commande pour les pages de man

> :warning: Ce script nécessite une version de bash >= pour s'éxecuter.
> Vous pouvez vérifier votre version avec `bash --version`

## Qu'est-ce que ce script fait ?

### Introduction

Ce script permet à son utilisateur de naviger à travers les pages de man
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

### Lancement du script a partir de Github

Pour executer ce script, vous pouvez lancer la commande suivante dans votre terminal :

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nsainton/Scripts/main/man_reader.sh)
```

<blockquote>

:bulb: Vous pouvez lancer
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nsainton/Scripts/main/man_reader.sh) bash 30
```
Pour plus d'information sur la **Process Substitution**

</blockquote>

Cela va afficher le menu principal et le script pourra etre execute comme specifie au-dessus.

En executant le script de cette maniere, les arguments peuvent etre specifies en ligne de commande
comme avec la commande `./man_reader.sh`

### Installation locale

Pour installer le script localement, dans `$HOME/.local/bin/man_reader`, vous pouvez lancer :
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nsainton/Scripts/main/man_reader.sh) -i
```
Par la suite, en ajoutant le chemin `$HOME/.local/bin/man_reader` a la variable PATH, vous pourrez lancer le script avec :
```bash
man_reader
```

### Affichage de la table des matieres

Pour afficher seulement la table des matieres de la page de man, vous pouvez lancer :
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nsainton/Scripts/main/man_reader.sh) -l [page]
```
Avec une page en argument optionnel. Si aucune page n'est entree, une page sera demandee en entree au demarrage du script.
La table des matieres de la page s'affichera et le script se terminera

### Lecture d'une seule page (pas de menu principal)

En lancant la commande suivante :
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nsainton/Scripts/main/man_reader.sh) -page [section]
```
Il est  possible d'afficher la page demandee (qui peut etre passee en argument en utilisant le format page.man\_section)
- Si aucune section (optionnelle) n'est donnee, le script ouvrira le menu principal pour la page de man et quitter quand l'utilisateur le demande
- Si une section est donnee en argument, le script affichera la section pour la page de man demandee.
Les sections peuvent etre specifiees dans deux formats :
	- Un nombre (entre 1 et le nombre de sections de la table des matieres) (ex : `man_reader bash 30`)
	- Une chaine qui decrit la section (ex : `man_reader bash 'Process Substitution`). N'oubliez pas les `'` ou `"` pour que la section soit traitee comme un seul argument

### Obtenir de l'aide

Executez la commande suivante :
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nsainton/Scripts/main/man_reader.sh) -h
```
Pour obtenir de l'aide sur l'utilisation du script

## Contribuer

Il y a deux manieres de contribuer a ce projet
- M'envoyer un message sur Discord ou Slack (pour les etudiants de 42) ou a ce [mail](mailto:nsainton@student.42.fr?subject=[man_reader])
- Les Pull-Request qui sont, pour le moment fermees mais seront bientot disponible pour vous permettre d'ajouter toutes vos incroyables features au projet
