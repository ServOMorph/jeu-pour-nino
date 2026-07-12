# Workflow optimal - generation d'animation

Objectif : produire une animation exploitable dans `game_art/`, sans frame corrompue, sans membre coupe, et avec affichage correct dans l'editeur.

Workflow de reference retenu : **generation de frames separees, validation frame par frame, puis assemblage en strip**.

La generation directe d'une grande strip est deconseillee : elle produit trop facilement des poses a cheval entre deux cases, des membres coupes ou des morceaux detaches.

Probleme supplementaire a eviter : une animation peut etre "propre" techniquement tout en restant mauvaise si la taille apparente du personnage varie d'une frame a l'autre. Le workflow doit donc imposer un **gabarit constant**.

## Regle absolue

- Toute animation a refaire doit etre regeneree completement depuis une frame de reference validee.
- Interdiction de recomposer, melanger, interpoler, reordonner, corriger localement ou recycler des morceaux de frames existantes.
- Si une vraie regeneration complete n'est pas possible, s'arreter.

## Principe de pipeline

Le bon pipeline est :

1. definir le cycle d'animation avant generation
2. decrire chaque frame comme une pose complete
3. generer chaque frame separement
4. valider chaque frame isolee
5. homogeniser cadrage, echelle et ligne de sol
6. assembler la strip finale
7. integrer dans `game_art/assets/`
8. valider dans l'editeur

Le mauvais pipeline est :

1. generer une grande image sequentielle
2. la couper en segments egaux
3. essayer de faire rentrer les poses dans les cases apres coup

## Phase 1 - Decoupage de l'animation

Avant toute generation, definir le cycle exact de l'animation.

Exemple type pour `run` :

1. contact avant
2. appui avant
3. passage
4. montee
5. contact inverse
6. appui inverse
7. passage inverse
8. montee inverse

Regles de decoupage :

- chaque frame doit correspondre a une pose lisible et complete
- la boucle doit etre pensee avant generation
- le nombre de frames doit etre fixe avant de lancer la generation
- la sequence doit etre symetrique seulement sur le mouvement principal, pas sur les tissus
- la tete doit rester relativement stable
- la variation doit surtout porter sur jambes, bras, bassin et manteau

## Phase 2 - Preparation des contraintes

Avant generation, verrouiller :

- frame size cible
- nombre de frames
- orientation du personnage
- ancrage au sol
- style identique a la reference
- silhouette et proportions identiques a la reference
- equipement constant entre toutes les frames
- gabarit de reference constant

Exemple `player/run` :

- `8` frames
- `87x150` par frame
- profil vers la droite
- meme personnage que `idle`
- meme echelle percue
- meme ligne de sol
- meme hauteur apparente et meme masse visuelle que la reference retenue

Pour durcir la methode, la reference ne doit plus etre seulement visuelle.
Elle doit etre mesuree avant generation.

## Phase 2bis - Gabarit de reference

Avant de generer, choisir une frame de reference validee, en general `idle`.

Mesures a figer a partir de cette reference :

- hauteur utile de silhouette
- largeur utile de silhouette
- position du personnage dans la frame
- ligne de sol
- marge haute minimale
- marge laterale acceptable

Regle :

- chaque frame regeneree doit rester dans une tolerance faible autour de ce gabarit
- si une frame s'ecarte trop, elle est rejetee et regeneree
- on ne compense pas un mauvais gabarit par un resize libre a l'assemblage

## Phase 2ter - Gabarit mesure et seuils de rejet

Avant generation, extraire une frame de reference runtime reelle et mesurer sa bbox utile.

Exemple `player/idle` actuel :

- frame cible : `87x150`
- bbox utile mesuree : `x=22`, `y=0`, `w=42`, `h=150`
- ligne de sol de reference : `149`

Ce gabarit devient la contrainte mecanique du lot.

Seuils recommandes pour accepter un lot :

- ecart de hauteur utile entre frames : `<= 3 px`
- ecart de ligne de sol entre frames : `<= 2 px`
- ecart de largeur utile entre frames : `<= 6 px`
- ecart de centrage horizontal du corps : faible et stable

Regles :

- si la hauteur utile derive au-dela du seuil, lot refuse
- si la ligne de sol derive au-dela du seuil, lot refuse
- si une frame exige un resize specifique a elle seule, lot refuse
- si le personnage semble plus "proche camera" sur certaines frames, lot refuse
- si la cape ou l'equipement modifie artificiellement la bbox au point de casser la stabilite globale, lot refuse

Le but n'est pas d'obtenir des images "belles" isoleement.
Le but est d'obtenir un lot stable a l'echelle animation.

## Phase 3 - Generation correcte des frames separees

Chaque frame doit etre generee separement.

La generation doit demander explicitement :

- regeneration complete de la frame
- une seule silhouette nette
- aucun ghosting
- aucun membre en double
- aucun debordement hors cadre
- pose complete, lisible et autonome
- fond uniforme de detourage si necessaire
- coherence stricte de style avec la reference et les autres frames

Chaque demande doit decrire :

- la pose exacte de la frame
- le numero de la frame
- la taille cible
- l'orientation
- la ligne de sol
- le gabarit de reference a respecter
- l'interdiction explicite de changer la distance camera
- l'interdiction explicite de changer la taille apparente du corps
- l'interdiction explicite d'elargir la silhouette par effet dramatique de cape

## Prompt type pour une frame

```txt
Generer la frame <N> de l'animation `<state>` du personnage depuis l'image de reference validee.

Contraintes obligatoires :
- regeneration complete de cette frame
- ne jamais recomposer, melanger, interpoler ou retoucher une frame existante
- une seule silhouette nette
- conserver exactement le meme personnage que la reference
- conserver le meme style, les memes proportions, la meme silhouette generale, la meme orientation, le meme equipement et la meme echelle percue
- conserver la meme hauteur apparente et le meme volume general que la frame de reference validee
- conserver la meme distance camera et le meme niveau de zoom que la frame de reference validee
- conserver la tete, le torse et le bassin dans une amplitude de deplacement faible a l'interieur du cadre
- la pose doit tenir entierement dans un cadre de <WIDTH>x<HEIGHT>
- alignement strict au sol
- aucun ghosting
- aucun membre en double
- aucun element coupe sur les bords
- aucun effet de perspective qui agrandit une jambe ou un bras vers la camera
- cape et tissus autorises seulement s'ils restent compacts et dans le gabarit
- fond vert chroma pur uniforme #00FF00

Pose demandee :
- <description precise de la pose>
```

## Phase 4 - Validation frame par frame

Ne jamais assembler une animation sans valider chaque frame.

Validation en deux passes obligatoires :

1. validation isolee de chaque frame
2. validation comparative du lot complet

Controles obligatoires pour chaque frame :

- la silhouette est complete
- aucun membre detache
- aucun morceau parasite sur les bords
- la pose tient entierement dans `frame_size`
- le haut du personnage ne touche pas le plafond
- la ligne de sol est correcte
- l'echelle est coherent avec les autres frames
- le style et le volume du personnage restent stables
- la hauteur utile reste dans la tolerance du gabarit de reference
- la largeur utile reste dans la tolerance du gabarit de reference
- le personnage n'apparait ni agrandi ni reduit par rapport a la reference

Si une seule frame echoue sur la coherence de lot, on rejette le lot complet et on regenere toutes les frames.

Tolerances recommandees :

- ecart de hauteur utile : `<= 3 px`
- ecart de largeur utile : `<= 6 px`
- ecart de ligne de sol : `<= 2 px`
- toute variation visible a l'oeil nu sur la taille du personnage doit etre consideree comme un echec
- si plusieurs frames sont correctes isoleement mais ne gardent pas un gabarit stable ensemble, le batch est refuse

Rejet precoce obligatoire :

- si les 3 premieres frames mesurrees derivent deja trop, on stoppe le batch
- on ne detoure pas, n'assemble pas et n'integre pas un lot deja hors tolerance
- on ne "teste pas quand meme dans l'editeur" pour un lot condamne metrologiquement

## Phase 5 - Homogeneisation avant assemblage

Quand toutes les frames sont valides :

1. extraire proprement le fond
2. conserver uniquement la silhouette utile
3. placer chaque frame dans sa case cible en conservant le gabarit retenu
4. aligner toutes les frames sur la meme ligne de sol
5. verifier la coherence globale de taille, volume et cadrage

## Phase 5bis - Normalisation automatique controlee

Une retouche automatique de taille et de position est autorisee si elle reste mecanique, faible et traçable.

Corrections autorisees :

- rescale leger pour homogeniser la hauteur utile
- recentrage horizontal
- alignement strict sur une ligne de sol commune
- normalisation de la marge haute

Corrections interdites :

- crop destructif pour faire rentrer une pose
- retouche manuelle d'un membre
- suppression locale d'un defaut de generation
- deformation non uniforme
- correction d'une seule frame qui change sa lecture par rapport au lot

Regles :

- la normalisation doit produire un rapport de correction par frame
- toute frame doit garder son ratio d'origine
- si une frame demande une correction trop forte, elle est marquee en anomalie
- si tout le lot demande une correction forte, le lot reste considere comme mauvais meme si une sheet "rentre" dans le cadre
- une sheet normalisee automatiquement peut etre produite pour validation manuelle, sans etre consideree validee de plein droit

Usage recommande :

- produire une `sheet candidate`
- verifier manuellement le rendu dans l'editeur
- remplacer l'asset runtime seulement apres validation visuelle

Interdictions :

- ne pas "forcer" une frame trop grande a rentrer par crop destructif
- ne pas redimensionner librement chaque frame pour compenser un gabarit incoherent
- ne pas accepter une frame avec fragment parasite
- ne pas assembler une frame douteuse en esperant corriger plus tard
- ne pas utiliser la phase d'homogeneisation pour corriger un probleme de generation

Resize autorise uniquement si :

- il est applique selon une regle unique et identique a toutes les frames du lot
- il ne change pas la perception de taille relative entre frames
- il sert seulement a convertir un lot deja coherent vers le format runtime final

Resize auto tolere en mode candidat si :

- il reste borne
- il est journalise
- il sert a preparer une validation manuelle plutot qu'a declarer le lot "bon"

Sinon : regeneration complete du lot.

## Phase 6 - Assemblage de la strip finale

Une fois toutes les frames homogenes :

1. creer la sheet finale
2. placer les frames dans l'ordre reel du cycle
3. verifier visuellement la strip complete
4. verifier qu'aucune frame n'est a cheval sur une autre

La strip finale doit etre une consequence mecanique de frames valides, jamais une etape d'interpretation.

## Phase 7 - Integration dans le projet

Quand la sheet est validee :

1. remplacer l'asset dans `game_art/assets/`
2. mettre a jour `game_art/data/animations.json`
3. regenerer `game_art/specs/<entity>.md` si necessaire

Pour `animations.json` :

- la liste `frames` doit refleter l'ordre reel de l'animation
- elle ne doit jamais servir a masquer une mauvaise sheet

## Phase 8 - Validation dans l'editeur

Validation obligatoire dans l'editeur avant de considerer l'animation utilisable.

Verifier :

- lecture fluide
- aucune frame coupee
- aucun fragment detache
- aucun saut d'echelle
- aucune variation visible de taille du personnage
- aucun decalage de sol
- aucun tremblement parasite du cadrage
- aucune impression de pose melangee

Si l'editeur montre une jambe isolee, un morceau de cape seul ou une pose tronquee, le probleme vient de la frame source ou de l'assemblage, pas de l'editeur.

## Checklist finale

- cycle de frames defini avant generation
- nombre de frames valide
- prompts de regeneration complete utilises
- chaque frame validee isoleement
- chaque frame mesuree contre la reference runtime
- lot refuse immediatement si hauteur, sol ou largeur derivent
- aucune frame ne deborde de sa case
- aucun fragment parasite
- gabarit constant respecte
- cadrage et ligne de sol homogenes
- sheet runtime assemblee au bon format
- `animations.json` mis a jour sans bricolage
- lecture validee dans l'editeur

## Cause racine a eviter

Le bug rencontre sur `run` venait de ce schema :

1. generation d'une grande strip visuelle
2. decoupage uniforme apres coup
3. recentrage/resize pour faire rentrer de force les poses dans `87x150`

Ce schema est interdit, car il produit facilement :

- membres coupes
- morceaux detaches
- poses a cheval entre deux frames
- ordre de lecture artificiellement corrige dans `animations.json`
- variation de taille apparente entre frames si chaque image est rescalee independamment

Le workflow correct consiste a generer des frames completement pensees pour le format cible, a les valider une par une contre un gabarit de reference stable, puis a assembler la strip finale seulement apres validation.
