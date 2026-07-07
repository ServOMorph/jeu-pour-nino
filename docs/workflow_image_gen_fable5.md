# Workflow image_gen pour sprites pixel art

Ce document resume le workflow teste dans cette session et les limites constatees.
Il sert de base de travail pour Fable 5 afin de trouver une solution fiable pour
produire des sprites pixel art de tres haute qualite.

## Objectif

Creer un process reutilisable pour produire tous les sprites du jeu avec une
qualite pixel art reelle, pixel par pixel, sans perdre la lisibilite ni la
coherence visuelle.

Le besoin n'est pas seulement de generer une image jolie. Le besoin est de
livrer un sprite exploitable en jeu, a la bonne taille, avec une silhouette
claire, des volumes lisibles et une palette controlee.

## Methode de travail utilisateur avec Codex

La methode voulue est la suivante :

1. l'utilisateur demande a Codex une image de reference ;
2. Codex utilise `image_gen` pour produire cette image ;
3. l'image de reference est voulue avec fond transparent ;
4. cette image sert uniquement de reference visuelle ;
5. un second workflow prend ensuite le relais pour fabriquer le vrai sprite final ;
6. ce sprite final est cree en pixel art a la taille exacte definie pour l'asset.

Important :
- l'image produite par `image_gen` n'est pas le sprite final ;
- elle sert de reference de forme, d'ambiance, de palette ou de matiere ;
- le vrai livrable doit etre reconstruit ensuite en pixel art a la bonne taille.

La chaine cible est donc :

`demande utilisateur -> image de reference via image_gen avec fond transparent -> workflow Fable 5 -> sprite final pixel art a la taille definie`

## Ce qui a ete teste

### 1. Minerai cuivre

On a commence par le minerai tier 1 parce que c'est un sprite simple.

Constat :
- `image_gen` peut aider a trouver une forme et une matiere de base.
- Un detourage + une reduction ne suffisent pas pour un sprite final propre.
- Le meilleur resultat obtenu a finalement ete une version construite a la main
  en grille fixe `14x14`.

Fichiers issus de ce test :
- `game_art/assets/objects/ore_copper_v2_test.png`
- `game_art/assets/objects/ore_copper_v3_test.png`
- `game_art/assets/objects/ore_copper_handmade_v2.png`

Conclusion :
- Pour un petit objet simple, `image_gen` peut servir de point de depart.
- Le livrable final doit rester un sprite controle pixel par pixel.

### 2. Sprite idle du personnage

On a ensuite applique le meme principe au joueur.

Constat :
- Le joueur ne doit pas etre traite comme un minerai.
- La bonne taille de travail est `40x56`, pas `14x24`.
- Les essais construits trop vite en blocs ou par reduction de l'image ne donnent
  pas un rendu assez qualitatif.
- La reference visuelle `player_idle_40x56_px_v1` est meilleure comme base que
  les essais trop generes ou trop simplifies.

Fichiers de travail :
- `game_art/assets/player/player_idle_40x56_px_v1.png`
- `game_art/assets/player/player_idle_40x56_px_v1_preview_x4.png`
- `game_art/assets/from_reference/player/terraria_ref_left.png`
- `game_art/assets/from_reference/player/terraria_ref_right.png`

Conclusion :
- Pour le joueur, le simple usage de `image_gen` ne suffit pas.
- Il faut un vrai travail pixel par pixel, a la bonne echelle, avec controle de
  la silhouette, des proportions, des volumes et des details.

## Principe image_gen

`image_gen` est l'outil integre de Codex pour generer ou modifier une image bitmap.
Dans ce projet, il sert a :

- produire rapidement une base visuelle ;
- tester une silhouette ou une idee de matiere ;
- creer des variantes de reference ;
- editer ou corriger un asset bitmap sans passer par un autre outil externe.

Workflow reel :
1. Je formule un prompt structure.
2. `image_gen` produit une image bitmap.
3. Le fichier est enregistre dans l'espace local de Codex.
4. Je verifie le resultat visuellement.
5. Si l'image doit servir au projet, je la copie dans le repo.
6. Si besoin, je fais une passe de detourage, de nettoyage ou de comparaison.

Limites importantes :
- `image_gen` n'est pas un editeur pixel-art de precision.
- Il ne garantit pas un vrai dessin pixel par pixel.
- Pour un sprite de personnage complexe, il produit souvent une base trop "rendue"
  ou trop lissee.
- Pour un sprite final de production, surtout un personnage, il faut ensuite une
  passe manuelle de pixel art.

## Pourquoi on veut l'utiliser

On veut utiliser `image_gen` parce qu'il est utile pour accelerer la phase de
recherche visuelle.

Il apporte :
- une base rapide pour explorer des formes ;
- une aide pour la matiere et les couleurs ;
- un gain de temps sur les premieres iterations ;
- un moyen simple de creer des previsualisations ou des planches de comparaison.

Ce qu'on ne veut pas faire :
- livrer une image `image_gen` brute comme sprite final ;
- confondre un rendu bitmap correct avec du vrai pixel art ;
- utiliser la reduction automatique comme substitut a un dessin pixel par pixel.

## Workflow retenu

Le workflow valide pendant la session est le suivant :

1. Partir d'une reference visuelle claire.
2. Definir la taille finale reelle du sprite.
3. Construire ou nettoyer le sprite pixel par pixel.
4. Generer une preview agrandie pour l'inspection.
5. Comparer avec la reference et corriger.
6. N'integrer l'asset au jeu qu'une fois la lisibilite validee.

Forme recommandee :
- petit objet simple : `reference -> sprite final -> preview x8 -> validation`
- personnage : `reference -> silhouette 40x56 -> pixel art manuel -> preview x4/x8 -> validation`

Version compatible avec la methode utilisateur :
- `image_gen` produit une reference transparente ;
- cette reference ne va pas directement dans le jeu ;
- Fable 5 doit ensuite transformer cette reference en sprite final pixel art ;
- la transformation doit respecter strictement la taille cible du sprite.

## Ce qui a echoue

Les approches suivantes n'ont pas donne un resultat satisfaisant :

- `image_gen -> detourage -> reduction -> asset final`
- sprite construit trop vite en masses sans vraie intention pixel par pixel
- transposition directe du workflow minerai vers le sprite du joueur

Le principal probleme est la perte de controle sur les pixels individuels.

## Ce que Fable 5 doit resoudre

Le point a resoudre pour Fable 5 est le suivant :

comment produire de vrais sprites pixel art de qualite, avec un controle assez fin
pour que le resultat final soit propre des la premiere version exploitable ?

La solution recherchee doit idealement permettre :
- un vrai controle pixel par pixel ;
- un respect strict de la taille finale ;
- une meilleure lisibilite des silhouettes ;
- un workflow repetable pour tous les sprites du jeu ;
- une separation claire entre reference, brouillon, preview et livrable final ;
- une articulation propre entre `image_gen` comme producteur de reference et
  Fable 5 comme producteur du sprite final.

## Recommandation pratique

Pour la suite, `image_gen` doit etre traite comme :
- un outil de recherche ;
- un outil de base visuelle ;
- un outil de preview ou de comparaison.

Il ne doit pas etre considere comme :
- l'outil final de production des sprites pixel art complexes ;
- une alternative au dessin pixel par pixel ;
- une garantie de style coherent pour le player.

## Resume court

`image_gen` est utile pour demarrer et explorer.
Le sprite final pixel art doit ensuite etre construit avec un vrai controle pixel
par pixel.

Dans la methode voulue par l'utilisateur, `image_gen` sert a produire une image
de reference avec fond transparent. Cette image est ensuite donnee a un second
workflow, que Fable 5 doit definir, pour fabriquer le vrai sprite final en pixel
art a la taille exacte demandee.

Pour le minerai, le workflow a ete acceptable.
Pour le personnage, il ne suffit pas.
Fable 5 doit donc trouver un workflow qui conserve la vitesse de l'IA, mais avec
la precision d'un vrai travail pixel art manuel.

---

## Solution Fable 5 (2026-07-06)

### Diagnostic

Analyse des fichiers existants :

| Fichier | Taille | Couleurs opaques | Semi-transparents |
|---|---|---:|---:|
| `player_idle_40x56_px_v1.png` (meilleure base) | 40x56 | 17 | 0 |
| `player_idle.png` (en jeu, reduction lissee) | 40x56 | 353 | 582 |
| `ore_abyssal.png` (en jeu) | 14x14 | 87 | 0 |
| `ore_copper_handmade_v2.png` (dessin manuel IA) | 14x14 | 8 | 0 |

Ce qui separe un bon sprite d'un mauvais est mesurable : palette limitee,
alpha binaire, structure preservee. Les deux echecs ont des causes distinctes :

- la reduction lissee (bilineaire/lanczos) produit des centaines de couleurs
  et des pixels semi-transparents : rendu boueux ;
- le dessin pixel par pixel from scratch par le modele produit une palette
  propre mais des volumes pauvres : rendu bloc.

La reference image_gen contient la bonne information visuelle. Le maillon
manquant etait une reduction qui detruit le bruit sans detruire la structure.

### Pipeline retenu

Outil : `game_art/tools/ref_to_sprite.py`

```
python game_art/tools/ref_to_sprite.py INPUT OUTPUT --size 14x14 --colors 8 --compare EXISTANT
```

Etapes automatiques :
1. binarisation alpha (zero pixel semi-transparent) ;
2. recadrage sur le contenu opaque ;
3. reduction par moyenne d'aire (BOX) a la taille cible exacte ;
4. boost saturation 1.4 / contraste 1.2 pour restaurer les accents ecrases
   par la moyenne (parametrable `--sat` / `--contrast`) ;
5. quantisation dure median cut a N couleurs, sans dithering ;
6. nettoyage : pixels orphelins retires, trous internes rebouches ;
7. sorties : sprite final + preview xN + planche contact
   (reference / resultat / asset existant) + audit chiffre.

Le mode `--mode vote` (couleur dominante par cellule) reste disponible pour
les sources deja en faux pixel art a gros blocs nets, mais sur le test reel
(`ore_abyssal_raw.png`, 850x892, 80k couleurs -> 14x14, 8 couleurs) le mode
average est nettement superieur : silhouette pleine, cristaux lisibles,
meilleur que l'asset actuellement en jeu.

### Workflow complet par sprite

1. Demander a image_gen une reference transparente haute resolution,
   un seul sujet, fond transparent ou chroma-key (voir
   `docs/process_generation_sprites.md` pour le prompt de base).
2. Deposer le brut dans `game_art/assets/generated_raw/<nom>_raw.png`.
3. Lancer `ref_to_sprite.py` avec la taille cible exacte et la palette max.
4. Inspecter la planche contact et la preview.
5. Passe de retouche ciblee pixel par pixel si necessaire : accents lumineux,
   silhouette, visage, mains. On corrige quelques pixels sur une base saine,
   on ne dessine jamais le sprite entier a la main.
6. Valider : audit `0 semi-transparents`, couleurs <= budget, lisible a 100%.
7. Integrer dans `game_art/assets/...` puis synchroniser vers le jeu.

### Budgets couleurs recommandes

| Type | Taille | Couleurs |
|---|---|---:|
| Petit objet (minerai, icone) | 14x14 a 28x28 | 6-8 |
| Objet moyen (etabli, porte) | ~58x40 | 10-12 |
| Personnage / ennemi | 40x56 | 14-20 |
| Boss | 96x128 | 20-24 |

### Repartition des roles

- `image_gen` : produit la reference (forme, matiere, palette, ambiance).
- `ref_to_sprite.py` : produit le sprite a la taille exacte, palette
  controlee, alpha binaire. C'est l'etape reproductible.
- Fable 5 : regle les parametres, inspecte la planche contact, fait la
  retouche ciblee finale. Jamais de dessin from scratch, jamais de
  reduction lissee livree telle quelle.

### Limite connue

Le pipeline garantit la proprete technique (taille, palette, alpha) et
preserve la structure, mais la qualite finale d'un personnage depend de la
qualite de la reference image_gen. Si la reference a une mauvaise pose ou
des proportions fausses, aucun parametre ne la rattrape : regenerer la
reference plutot que forcer la retouche.
