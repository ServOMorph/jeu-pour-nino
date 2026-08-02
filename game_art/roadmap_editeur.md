# Roadmap - Editeur de sprites & animations (game_art)

## Objectif
Outil Godot autonome permettant de visualiser tous les sprites du jeu en taille reelle
(echelle jeu), lire leurs animations a l'identique du jeu, editer les timings/offsets,
et detecter les sprites manquants ou orphelins. Pas de generation ni de retouche
artistique de sprite (les graphismes sont produits par Codex/ChatGPT) : l'editeur
permet uniquement un ajustement geometrique manuel du cadrage d'une frame deja
generee (redimensionnement uniforme + position, contraint a sa case dans la sheet),
en complement du workflow de normalisation automatique.

## Articulation avec la zone jeu
- `game_art/backlog_art.md` est l'entree de production : les assets a produire viennent
  des phases de `roadmap.md` (racine), jamais de cette roadmap-ci.
- `questions.md` (racine) est la source d'arbitrage commune en cas de doute de conception.
- L'editeur est l'outillage de la chaine `production -> reglage/audit -> sync.py -> validation en jeu`.
  Il ne conditionne aucune phase jeu (regle placeholders de `roadmap.md`).

## Perimetre
Couvert : sprites et animations d'entites (player, ennemis, boss, Gardiens, porteurs)
via `animations.json` + manifest d'audit.
Hors perimetre (valides directement en jeu, pas dans l'editeur) : tilesets et
parallax (phases jeu 4/7), shaders et overlays des cicatrices (phase 6), icones UI
(Grimoire, slots d'equipement, cicatrices), sprites de gisements, projectiles.
Si un besoin de previsualisation apparait pour ces types, ouvrir une phase 6
« Extensions v3 » tiree par la phase jeu concernee — ne pas l'anticiper.

## Regle de synchronisation du manifest
Toute entree de `backlog_art.md` impliquant une entite animee (nouveaux archetypes
ennemis, boss de biome, Gardiens, porteurs, modules du Miroir) ajoute son entite au
manifest d'audit AVANT production des sheets. L'audit « sprites manquants » ne detecte
que ce que le manifest connait : un manifest non tenu a jour rend l'audit vert menteur.

## Etat de progression

- Phase 0 : close
- Phase 1 : close
- Phase 2 : close
- Phase 3 : close
- Phase 4 : close
- Phase 5 : close
- Phase 6 : close
- Phase 7 : en_cours

## Phase 5 - Finitions

- [x] Validation en jeu du set player synchronise : cycle `asset -> sync -> verification en jeu`
      execute une fois avec le set joueur HD retenu.
- [x] Fiche de specs par entite : export Markdown `game_art/specs/<entity>.md`
      avec tailles, etats, timings, sheets et anomalies ouvertes.
- [x] Migration spritesheet complete : tous les etats player utilisent maintenant
      `sheet` + `frame_size` + indices, sans fallback legacy cote jeu/editeur.
      Les etats mono-frame sont encapsules en sheets 1 frame ; cela clot la migration
      de format, pas une eventuelle refonte visuelle future.
- [x] Documentation d'usage : `game_art/README.md` pour lancer l'editeur, editer,
      sauver, auditer, synchroniser et suivre les conventions de nommage.

#### Fait quand
Un cycle complet `sheet produit -> depot assets -> visualisation/reglage dans l'editeur
-> audit vert -> sync -> validation en jeu` est execute une fois.
Support concret retenu : les sprites player standard Terraria-like (entree `livre`
de `backlog_art.md`, signal P3 de `_contexte/signals.md`) — premier remplacement de
placeholder reel, priorite 1 de la regle Q071 (joueur > ennemis > boss > tilesets > UI).

## Phase 6 - Extensions v3

Ouverte par necessite concrete (regle "ne pas anticiper" de la section Perimetre) :
session game_art 2026-07-06 en cours sur les sprites de gisements/minerais
(`Sprites gisements/minerais par type de materiau`, backlog_art.md), besoin de
validation visuelle immediate.

- [x] Previsualisation des sprites de gisements/minerais (objects/ore_*.png) dans
      le panneau preview de l'editeur, a l'echelle jeu.

Perimetre de cette phase : uniquement les gisements/minerais, tires par le besoin
ci-dessus. Tilesets 2D standard, parallax, shaders/overlays cicatrices et icones UI restent hors
perimetre tant qu'aucun besoin concret equivalent n'apparait (cf. Perimetre).

## Phase 7 - Pipeline d'animations video guidees

### Objectif

Remplacer, pour les nouvelles regenerations d'animations, la production de frames
independantes par une generation temporelle guidee par un cycle de poses fixe. Le
premier cas de validation est `player/run` : `16` frames, cases runtime `104x150`,
lecture a `16 fps` et cycle d'une seconde.

Le but est d'obtenir simultanement :

- un mouvement fluide et cyclique ;
- une identite visuelle stable sur toutes les frames ;
- une echelle constante du personnage ;
- un bassin stable horizontalement ;
- des pieds d'appui alignes sur une ligne de sol commune ;
- aucun recadrage, recentrage ou redimensionnement individuel apres generation.

### Decisions de pipeline

- Generer l'animation complete comme une seule sequence video guidee, puis extraire
  les frames dans leur ordre naturel.
- Utiliser une seule reference HD validee pour l'identite du personnage.
- Piloter le mouvement avec une video de poses deterministe, produite avec une camera
  orthographique fixe et un personnage courant sur place.
- Executer `Wan2.2-Animate` quantifie localement avec offload RAM. La RTX 4060 `8 Go`
  a valide une generation `512x736`, `81` frames, `20` etapes sans OOM en environ
  `35` minutes ; aucun backend distant n'est autorise.
- Le mode animation a preserve l'identite mais insuffisamment respecte la course avec
  un controle realiste. Le prochain essai utilise le mode remplacement et un controle
  pre-normalise, afin de conserver plus strictement la geometrie source.
- `MimicMotion`, SCAIL2, SD1.5, Flux et le rendu direct TripoSR/UniRig restent des
  pistes rejetees pour le candidat final dans leur configuration testee.
- Ne jamais utiliser une generation image par image comme source finale d'une nouvelle
  animation.
- Ne jamais remplacer `player_run_sheet.png` avant validation complete du candidat.
- Toute refonte regenere toutes les frames depuis la reference validee. Aucun melange,
  recyclage, interpolation, reordonnancement ou retouche locale de frames existantes.

References techniques :

- [Wan2.2-Animate](https://github.com/Wan-Video/Wan2.2)
- [Workflow Wan2.2-Animate pour ComfyUI](https://docs.comfy.org/tutorials/video/wan/wan2-2-animate)
- [MimicMotion](https://github.com/Tencent/MimicMotion)
- [Animate Anyone](https://arxiv.org/abs/2311.17117)

### Etape 7.1 - Profil reproductible de l'animation

- [ ] Creer un profil de generation versionne pour `player/run` contenant :
      reference source, backend, modele, seed, prompt, taille du canevas, nombre de
      frames, fps, frame runtime et seuils de controle.
- [x] Stocker les sources de travail dans
      `game_art/assets/generated_raw/player/run_video_v1/` sans modifier les assets
      runtime existants.
- [ ] Conserver les empreintes des fichiers d'entree et la configuration exacte dans
      un rapport JSON afin de pouvoir reproduire le lot.

### Etape 7.2 - Cycle de poses de controle

- [x] Produire un cycle de course sur place de `16` phases regulieres : contact,
      amorti, passage et montee, puis les quatre phases opposees et leurs transitions.
- [x] Utiliser un canevas de ratio strictement identique a `104x150`.
- [x] Verrouiller la camera, la longueur apparente du squelette, l'axe horizontal du
      bassin et la ligne de sol.
- [x] Verifier que la transition implicite `frame 15 -> frame 0` est aussi courte et
      naturelle que les transitions internes.
- [x] Exporter la video de controle sans mouvement de camera, sans zoom et sans
      deplacement horizontal global du personnage.

### Etape 7.3 - Reference personnage

- [x] Choisir une reference HD validee du player, orientee vers la droite et montrant
      integralement le personnage, l'armure, la cape et l'epee.
- [x] Placer cette reference sur un canevas de meme ratio que la video de controle.
- [x] Aligner tete, bassin et ligne de sol avec la premiere pose de controle.
- [x] Utiliser un fond chroma uniforme, sans ombre, texture, gradient ni reflet.
- [x] Faire valider cette reference avant toute generation du lot complet.

### Etape 7.4 - Generation temporelle

- [ ] Generer les `16` frames en une seule execution avec la reference personnage et
      la video de controle.
- [ ] Fixer le seed, le modele, le prompt, la resolution et tous les parametres ; ne
      modifier aucun parametre entre les frames.
- [ ] Demander une camera fixe, une silhouette complete, une identite constante et un
      fond chroma uniforme.
- [ ] Rejeter le lot complet en cas de membre coupe, personnage duplique, mutation de
      l'equipement, changement de camera ou rupture temporelle visible.

### Etape 7.5 - Extraction sans correction individuelle

- [ ] Extraire toutes les frames dans l'ordre temporel d'origine.
- [ ] Detourer le fond avec les memes parametres pour tout le lot.
- [ ] Appliquer une unique transformation uniforme du canevas complet vers `104x150`.
- [ ] Interdire tout crop, resize, offset ou recentrage propre a une frame.
- [ ] Assembler directement la sheet candidate `1664x150` a partir des `16` frames.
- [ ] Conserver la video brute, les frames brutes, les frames detourees et le rapport
      de transformation dans `generated_raw/`.

### Etape 7.6 - Controle automatique

- [ ] Verifier le nombre de frames, leurs dimensions, leur ordre et l'absence de pixels
      opaques sur les bords du canevas.
- [ ] Comparer les points de pose generes aux points de controle, plutot que comparer
      uniquement les bbox, car l'extension des membres change naturellement la largeur.
- [ ] Utiliser comme seuils initiaux : variation tete-bassin `<= 2 %`, derive
      horizontale du bassin `<= 1,5 %` du canevas et derive du pied d'appui `<= 1 px`
      a l'echelle runtime. Calibrer ces seuils sur le premier lot sans les assouplir
      pour faire accepter un resultat visuellement mauvais.
- [ ] Detecter les variations d'identite sur le visage, l'armure, l'epee et la cape.
- [ ] Comparer la transition `15 -> 0` aux transitions internes et rejeter toute
      rupture de boucle nettement superieure.
- [ ] Produire un rapport JSON avec verdict global, mesures par frame et motifs de rejet.
- [ ] Si une frame echoue, rejeter et regenerer les `16` frames. Ne jamais corriger ou
      regenerer une frame isolee.

### Etape 7.7 - Validation editeur et jeu

- [ ] Ajouter la sheet candidate comme nouvel asset versionne, sans ecraser la sheet
      runtime validee.
- [ ] Brancher temporairement le candidat dans l'editeur a `16 fps`, boucle active.
- [ ] Verifier a taille reelle : fluidite, stabilite du torse, contacts au sol,
      silhouette, identite, cape, epee et raccord de boucle.
- [ ] Regenerer le lot complet si la lecture visuelle echoue, meme si l'audit metrique
      est vert.
- [ ] Apres validation manuelle, remplacer l'asset runtime, mettre a jour
      `animations.json`, lancer `sync.py` puis valider dans le jeu.
- [ ] Archiver la precedente sheet hors runtime seulement apres validation en jeu.

### Etape 7.8 - Generalisation

- [ ] Parametrer les scripts d'extraction, de detourage, d'audit et d'assemblage pour
      les autres entites et tailles de frame.
- [ ] Ajouter un profil par animation ; ne jamais reutiliser les seuils de `run` sans
      verification pour une animation aerienne, une attaque ou un boss.
- [ ] Documenter la commande complete de reproduction d'un lot valide.
- [ ] Conserver une validation manuelle obligatoire : l'automatisation doit rejeter les
      erreurs evidentes, pas declarer seule qu'une animation est artistiquement valide.

#### Fait quand

- `player/run` contient `16` frames integralement regenerees depuis une reference HD
  validee et une video de poses fixe ;
- aucune frame n'a subi de correction geometrique individuelle ;
- les controles de pose, de placement, de taille, de bord et de boucle sont verts ;
- la lecture est validee dans l'editeur a `16 fps` puis dans le jeu ;
- le profil, le seed, les sources, la video, les frames et le rapport permettent de
  reproduire et d'auditer le lot ;
- l'ancienne animation reste recuperable.

### Risques et blocages

- L'execution locale est faisable mais lente : environ `35` minutes pour un lot
  `512x736`, `81` frames, `20` etapes, avant audit et nouvelles iterations.
- La generation video ameliore fortement la coherence temporelle mais ne garantit pas
  l'absence de mutations visuelles : les controles automatiques et manuels restent
  obligatoires.
- Les seuils de pose doivent etre calibres sur le premier prototype, puis figes avant
  la generation candidate finale.
- Un fond chroma imparfait peut degrader les contours fins de la cape et des cheveux ;
  le detourage doit etre valide avant le resize runtime.
- Le candidat 37 a ete rejete : identite propre mais mouvement presque fige et mauvaise
  alternance des jambes. Une execution materiellement reussie n'est pas une validation.

## Apres Phase 5 : maintenance

Une fois la Phase 5 close, l'editeur passe en maintenance : plus d'evolution d'outillage
sauf besoin concret tire par une entree de `backlog_art.md` (cf. Perimetre ci-dessus).
Le temps de la zone game_art va a la production d'assets, pas au polissage de l'outil.
La preview d'entite rend a la resolution affichee et utilise le filtrage lineaire du jeu ;
le test `test_preview_center.gd` couvre le centrage player et le cadrage du boss.

## Commandes de reference

| Action | Commande |
| --- | --- |
| Lancer l'editeur | `python run_editeur.py` |
| Ouvrir le projet editeur dans Godot | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --path game_art --editor` |
| Lancer le jeu (sync incluse) | `python run_game.py` |
| Sync seule | `python sync.py` |
| Test audit moteur | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit.gd` |
| Test audit UI | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit_ui.gd` |
| Test centrage preview | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_preview_center.gd` |
| Test export specs | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_specs_export.gd` |
| Test edition sheet | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_sheet_editor.gd` |

## Point d'attention

La migration de format est close pour le player et ses PNG legacy sont archives hors
audit. Les etats `player/idle`, `player/attack` et les 4 attaques directionnelles sont
valides en lecture editeur. `player/jump` est maintenant une sheet `3` frames et
`player/run` utilise des cases `104x150` pour faciliter l'edition manuelle.
Le bouton `Recharger` est aussi valide en session ouverte.
Le runtime `game/` est maintenant realigne sur `player/run` et `player/jump`, et
`player/attack` utilise des cases `150x150` apres elargissement lateral de la sheet.
L'editeur est maintenant pilote a la souris uniquement ; les evenements manette y sont bloques.
Le workflow de regeneration d'animation a maintenant ete confirme sur les mobs standards :
`enemy_ground/walk` et `enemy_flyer/fly` sont valides sur l'etat courant apres controle
dans l'editeur.
Le bouton `Editer sheet` permet desormais un ajustement manuel (scale uniforme + position,
contraint a la case) des frames de l'etat selectionne, pour corriger un cadrage sans
regeneration complete ; il ecrit directement le PNG source de la sheet.
La session biome 1 du 2026-08-01 a complete la passe decor/parallax avec une texture
de terrain runtime : les plateformes ne reposent plus sur des placeholders colores.
