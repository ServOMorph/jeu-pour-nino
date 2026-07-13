# Backlog art - CoreDive Challenge

Backlog des assets a produire pour la zone jeu. Alimente par les phases de `roadmap.md` (racine) : chaque phase jeu qui pose un placeholder ajoute une entree ici. Les sessions game_art piochent dedans par priorite.

## Pivot 2026-07-07 - abandon du pixel art, graphismes 2D standard

Decision jeu : le style visuel passe du pixel art a de la 2D standard (raster haute resolution lissee, plus de grille ni de palette reduite). Plan complet : `plan_graphismes_standard_2d.md` (racine). S'articule avec `plan_resolution_1920x1080.md` (resolution native 1920x1080 conservee).

Pipeline de production retenu : generation d'image via le module Codex, puis rescale a la taille de rendu cible (pas de dessin manuel, pas de vectoriel, pas d'asset packs). Point de vigilance signale au plan : derive de cadrage/echelle entre frames d'une meme animation generees separement - a controler avant integration.

Consequences pour cette zone (a traiter cote game_art, hors perimetre jeu) :
- `docs/charte_graphique_pixel_art_dark_fantasy.md` et `docs/workflow_image_gen_fable5.md` : obsoletes, a reecrire pour le nouveau pipeline (voir plan section 3).
- `game_art/tools/ref_to_sprite.py` : sans objet (reduction pixel), a remplacer par un script de rescale simple.
- Editeur (`game_art/editeur/`) : filtre de preview aligne sur le lineaire runtime et rendu a la resolution affichee ; les anciens libelles de preview "x8" et l'audit de tailles sur grille restent a refondre.
- Toutes les entrees ci-dessous portant une spec en grille pixel (14x14, 16x16, palette limitee) sont a reviser vers des tailles 2D standard a resolution native - la colonne `specs:` reste la propriete de l'agent game_art.
- La precision "Grille de tiles : 16x16" ci-dessous est revisee : plus de grille imposee.

## Precisions v3.1 (questions.md, 2026-07-06)

77 questions de conception (+ Q026b) ont ete tranchees avant le developpement - voir `questions.md` a la racine du projet. Les entrees ci-dessous integrent deja ces decisions. Points de cadrage transverses a connaitre avant de produire :

- **Pas de grille de tiles imposee** : les decors sont desormais produits en 2D standard a resolution native 1920x1080.
- **2-3 couches de parallax** par biome (fond lointain + intermediaire + premier plan).
- **Style dark fantasy** (voir `docs/charte_graphique_pixel_art_dark_fantasy.md`) - pas l'imagerie "lumineuse arcade" suggeree par endroits dans les docs v3 historiques.
- **Un seul Gardien du Voile au lancement** (Le Veilleur des Cendres) - ne pas produire les 7 autres avant que la roadmap jeu (refacto R2) ne les active.
- **Rarete/biomes realignes** : cristaux -> Biome 3 (Iles Celestes), imagerie volcanique -> Biome 4 (Descente vers le Noyau). Ne pas suivre d'anciennes versions des docs qui inversaient ces deux biomes.
- **Cicatrices visuelles = 5 paliers fixes**, shaders + overlays uniquement, jamais de retouche de spritesheet (detail des paliers dans l'entree dediee ci-dessous).

## Regles

- Une phase jeu n'est "faite" que si ses placeholders sont recenses ici.
- Priorite heritee des jalons jouables : ce qui est visible dans le jalon courant passe devant.
- Livraison : produire dans `game_art/assets/` + `game_art/data/animations.json`, puis sync.py -> `game/`. Ne jamais editer `game/assets/sprites/` directement.
- Manifest d'audit : toute entree impliquant une entite animee (nouvel archetype ennemi, boss, Gardien, porteur, module du Miroir) ajoute son entite au manifest de l'editeur AVANT production des sheets - sinon l'audit "sprites manquants" ne la verra jamais (cf. `roadmap_editeur.md`, regle de synchronisation du manifest).
- Standard visuel : Terraria-like, ref `docs/process_generation_sprites.md`.
- Statuts et propriete des transitions :
  - `a_faire` -> `en_cours` -> `livre` : possede par l'agent game_art.
  - `livre` -> `integre` : possede par l'agent jeu, une fois l'asset branche cote `game/`.
  - Ce fichier est l'unique canal de handoff entre les deux agents. Aucun autre fichier (`_contexte/signals.md` d'une zone ou de l'autre) ne doit porter le statut ou la priorite d'un item art - au besoin, y referencer l'entree par son nom.
- Champs de handoff (voir format d'entree) :
  - `debloque:` - rempli par l'agent jeu a la creation de l'entree : quelle tache/phase dev ce visuel debloque.
  - `livraison:` - rempli par l'agent game_art au passage a `livre` : chemin exact des fichiers produits (assets + entree `animations.json` le cas echeant).

## Format d'entree

```
### <nom de l'asset>
- phase: <phase jeu d'origine>
- placeholder: <ce qui est en jeu actuellement>
- specs: <dimensions, format, contraintes>
- priorite: <haute | moyenne | basse>
- statut: a_faire
- debloque: <tache/phase dev bloquee tant que cet asset n'est pas integre>
- livraison: <chemin des fichiers produits - rempli au passage a "livre">
```

---

## Entrees

### Sprites player - standard Terraria-like
- phase: anterieure (P3 signals)
- placeholder: sprites actuels hors standard
- specs: nouvelle cible definitive joueur = 150 px de haut ; idle/jump/fall/hurt/dead en 87x150, run en sheet `104x150`, attack en 150x150
- priorite: haute
- statut: integre
- livraison: `game_art/assets/player/player_idle_v2.png`, `game_art/assets/player/player_run1.png`, `game_art/assets/player/player_run2.png`, `game_art/assets/player/player_jump.png`, `game_art/assets/player/player_attack.png`, `game_art/assets/player/player_attack_transition.png`, `game_art/assets/player/player_attack_up.png`, `game_art/assets/player/player_attack_up_transition.png`, `game_art/assets/player/player_attack_up_diag.png`, `game_art/assets/player/player_attack_up_diag_transition.png`, `game_art/assets/player/player_attack_down.png`, `game_art/assets/player/player_attack_down_transition.png`, `game_art/assets/player/player_attack_down_diag.png`, `game_art/assets/player/player_attack_down_diag_transition.png`, `game_art/assets/player/player_run_sheet.png`, `game_art/assets/player/player_idle_sheet.png`, `game_art/assets/player/player_jump_sheet.png`, `game_art/assets/player/player_fall_sheet.png`, `game_art/assets/player/player_hurt_sheet.png`, `game_art/assets/player/player_dead_sheet.png`, `game_art/assets/player/player_attack_sheet.png`, `game_art/assets/player/player_attack_up_sheet.png`, `game_art/assets/player/player_attack_down_sheet.png`, `game_art/assets/player/player_attack_up_diag_sheet.png`, `game_art/assets/player/player_attack_down_diag_sheet.png`, `game_art/data/animations.json`
- note: cette entree est aussi le support du "Fait quand" de la Phase 5 de `roadmap_editeur.md` (premier cycle complet sheet -> editeur -> audit -> sync -> validation en jeu). En maintenance 2026-07-09 : `player/attack` a ete regenere integralement depuis une frame de reference ; la sequence visee est `0,1,2,3,3,3,2,1,0`. En maintenance 2026-07-10 : `player/idle` a ete refait en 6 frames ; la lecture courante ignore `4.0` et vise `0,1,2,3,5`. En maintenance 2026-07-11 : les 4 attaques directionnelles et `idle` sont valides dans l'editeur. En maintenance 2026-07-12 : `player/attack` et le flux `Recharger` sont valides manuellement en session ouverte. En maintenance 2026-07-12 : `player/run` est regenere via frames separees + normalisation automatique controlee ; `player/jump` est regenere en `3` frames depuis la reference validee et `player/run` est reconditionne en cases `104x150` pour faciliter l'edition dans l'editeur. En maintenance 2026-07-13 : `player/jump` et `player/run` sont resynchronises puis valides en jeu ; `player/attack` passe en `150x150` et reste valide apres controle manuel.

### Animations mobilite - double saut, corde/grappin
- phase: 2 - Grimoire/PC/Craft (mobilite definie questions.md Q015)
- placeholder: aucune animation dediee (saut simple uniquement actuellement)
- specs: frame(s) additionnelle(s) pour le double saut (variation de la pose de saut existante), animation d'utilisation de la corde/grappin (lancer + traction). Pas de dash, pas de wall jump a prevoir.
- priorite: moyenne
- statut: a_faire

### Mobs standards placeholder - ground et flyer
- phase: anterieure (maintenance runtime)
- placeholder: mobs standard a image unique sans vraie animation de deplacement, avec incoherences de style entre `idle` et mouvement
- specs: `enemy_ground` en `128x128` avec `idle` regenere et `walk` en 8 frames ; `enemy_flyer` en `112x80` avec `idle` regenere et `fly` en 6 frames. Les sheets runtime actuelles sont validees en lecture editeur sur l'etat courant.
- priorite: moyenne
- statut: livre
- debloque: validation du workflow d'animation sur mobs et remplacement des placeholders ennemis visibles en jeu
- livraison: `game_art/assets/enemies/enemy_ground.png`, `game_art/assets/enemies/enemy_ground_walk_sheet.png`, `game_art/assets/enemies/enemy_flyer.png`, `game_art/assets/enemies/enemy_flyer_fly_sheet.png`, `game_art/data/animations.json`, `game_art/assets/generated_raw/enemy_ground_walk_sheet_candidate.json`, `game_art/assets/generated_raw/enemy_flyer_fly_sheet_candidate.json`

### Sprites gisements/minerais par type de materiau
- phase: 1 - Materiaux types
- placeholder: `ore_copper.png` unique pour tous les gisements
- specs: un sprite par materiau, lisible en 2D standard a la taille runtime des gisements (`56x56` actuellement cote jeu) - 13 definitifs (questions.md Q041) : `bois`, `pierre`, `cuivre`, `cuir` (B1), `fer`, `charbon`, `minerai_sombre` (B2), `cristal`, `minerai_celeste`, `essence_vent` (B3), `fragment_noyau`, `minerai_abyssal` (B4), `essence_voile` (Voile, drop uniquement, pas de gisement). Lisibilite de rarete croissante (charte graphique).
- priorite: moyenne
- statut: livre
- livraison: `game_art/assets/objects/ore_bois.png`, `game_art/assets/objects/ore_pierre.png`, `game_art/assets/objects/ore_copper_handmade_v2.png`, `game_art/assets/objects/ore_iron.png`, `game_art/assets/objects/ore_charbon.png`, `game_art/assets/objects/ore_minerai_sombre.png`, `game_art/assets/objects/ore_cristal.png`, `game_art/assets/objects/ore_minerai_celeste.png`, `game_art/assets/objects/ore_fragment_noyau.png`, `game_art/assets/objects/ore_abyssal.png`

### Sprite manquant - minerai abyssal
- phase: 1 - Materiaux types
- placeholder: le jeu utilise encore le sprite generique cuivre pour `minerai_abyssal`
- specs: sprite dedie pour `minerai_abyssal`, coherent avec un materiau tier 3 / biome 4, clairement distinct visuellement de `ore_copper.png` et `ore_iron.png`
- priorite: haute
- statut: integre
- debloque: cloture Phase 1 roadmap.md - lisibilite du test manuel tier 3
- livraison: `game_art/assets/objects/ore_abyssal.png`

### Icones d'equipement - 4 slots
- phase: 2 - Grimoire/PC/Craft
- placeholder: aucun (auto-equipement sans UI dediee)
- specs: ecran d'equipement manuel (questions.md Q055) - icones pour 4 slots : Arme (melee ou distance), Armure, Accessoire, Outil. Une icone par objet equipable de la table de 27 recettes (Q043).
- priorite: moyenne
- statut: a_faire

### Sprites armes a distance + projectiles
- phase: 2 - Grimoire/PC/Craft
- placeholder: aucun (arme a distance non existante actuellement)
- specs: Arc en Bois, Arbalete de Fer, Arc Celeste, Bombe Instable (questions.md Q043) - sprite arme + sprite/anim de projectile en vol + impact. Coherent avec le melee existant (pas de refonte de style).
- priorite: moyenne
- statut: a_faire

### Grimoire - mise en page et icones
- phase: 2 - Grimoire/PC/Craft
- placeholder: UI Godot brute (labels/rects)
- specs: ecran de deblocage des recettes, **accessible au HUB uniquement** (questions.md Q056), icones pour les 27 recettes definitives (Q043) par rarete (commune/peu commune/rare/epique/legendaire/Voile)
- priorite: moyenne
- statut: a_faire

### Decor du HUB
- phase: 3 - HUB (jalon J1)
- placeholder: rects colores
- specs: point central + 4 directions visibles, composition pensee pour un ecran fixe 1920x1080. Le HUB reste minimal (4 sorties, Grimoire, etabli) - pas de decor evolutif en v3 (questions.md Q039).
- priorite: haute
- statut: integre
- debloque: Phase 3 - HUB et selection de biome (jalon J1)
- livraison: `game_art/assets/tiles/hub_decor.png` (branche en fond via `game/data/hub.json`)

### Script de rescale ref_to_sprite.py
- phase: pivot pixel art -> 2D standard (2026-07-07)
- placeholder: `game_art/tools/ref_to_sprite.py` encore en logique pixel art (binarisation alpha, quantisation de palette median cut, `--size` en grille type 14x14) - dernier residu du pivot identifie lors d'un audit cote jeu le 2026-07-12
- specs: remplacer par un script de rescale simple (resize exact vers la taille runtime cible, sans quantisation de palette ni binarisation en grille), conforme au pipeline decrit dans `docs/process_generation_sprites.md`
- priorite: basse
- statut: a_faire
- debloque: aucun bloquant dev direct - dette d'outillage residuelle du pivot art

### Objet/portail de sortie volontaire de biome
- phase: 3 - HUB (jalon J1)
- placeholder: aucun
- specs: objet ou portail visible dans chaque biome, permettant un retour au HUB en cours d'exploration sans mourir ni battre le boss (questions.md Q006)
- priorite: basse
- statut: a_faire

### Tileset et decors - Biome 1 Galeries Verdoyantes
- phase: 4 - Generation biomes (jalon J2)
- placeholder: rects/polygones colores
- specs: decors 2D standard a resolution native, sans grille imposee, compatibles avec 8-10 templates de salles (5-7 salles par run, connexions 4 directions), 2-3 couches de parallax (Q069), ambiance cavernes vegetales, lumiere filtrante
- priorite: haute
- statut: a_faire

### Overlay d'obscurite - Biome 2 (Mines Obscures)
- phase: 4/7a - Generation biomes / Mines Obscures
- placeholder: aucun
- specs: overlay/vignette sombre plein ecran, active quand la Torche n'est pas equipee (slot Outil) - pas de Light2D dynamique a rayon suivant le joueur (questions.md Q018/Q021). Doit rendre le biome reellement difficile a lire sans la Torche, sans bloquer totalement la visibilite.
- priorite: moyenne
- statut: a_faire

### Decor Arene du Voile - tribunal cosmique
- phase: 5 - Mort/Resurrection
- placeholder: rects colores
- specs: plateforme suspendue, ciel fracture, fragments de biomes flottants
- priorite: moyenne
- statut: a_faire

### Sprites et patterns visuels - Le Veilleur des Cendres (Gardien unique de lancement)
- phase: 5 - Mort/Resurrection
- placeholder: sprite boss actuel recolore
- specs: **un seul Gardien a produire au lancement** (questions.md Q029) - theme cendres/braises, coherent avec ses 3 attaques (charge au sol, projectile de cendres, zone d'explosion retardee) + pose de pause vulnerable. Les 7 autres Gardiens du pool (Roi Sans Visage, Collecteur d'Ames, Veuve du Vide, Devoreur de Souvenirs, Porte-Flamme, Gardien des Os, Echo du Noyau) ne sont a produire qu'apres activation de R2 cote jeu - ne pas anticiper.
- priorite: moyenne
- statut: livre
- livraison: `game_art/assets/enemies/boss_guardian_ashes.png`, `game_art/assets/enemies/boss_guardian_ashes_pause.png`, `game_art/assets/enemies/boss_projectile_ash.png`, `game_art/data/animations.json`, `game/scenes/enemies/boss_projectile.tscn`

### Effets visuels cicatrices - 5 paliers fixes
- phase: 6 - Cicatrices (jalon J3)
- placeholder: aucun effet visuel
- specs: shaders + overlays de particules UNIQUEMENT, zero modification des spritesheets (questions.md Q070). Paliers definitifs : **1** overlay lumineux (yeux) + particules discretes ; **2** shader teinte veines lumineuses + halo ; **3** shader transparence partielle ; **4** overlay fragments flottants + teinte cristalline ; **5+** combinaison de tous les shaders precedents a intensite maximale + particules denses. Outils Godot standards (shaders 2D, CPUParticles2D).
- priorite: moyenne
- statut: a_faire

### Icones des 5 cicatrices - HUD
- phase: 6 - Cicatrices (jalon J3)
- placeholder: aucun
- specs: une icone par cicatrice definitive (questions.md Q026) - Cicatrice du Sang, de l'Os, de l'Ame, de la Peur, du Noyau - affichees en rangee dans le HUD
- priorite: basse
- statut: a_faire

### Biome 2 Mines Obscures - ennemis, boss, tileset
- phase: 7a (jalon J4)
- placeholder: assets biome 1 recolores
- specs: sprites ennemis (questions.md Q050) - Mineur spectral (`ground`), Golem de pierre (`ground` tanky), Araignee geante (`jumper` - nouvel archetype bondissant), Machine abandonnee (`turret` - nouvel archetype stationnaire tirant). Boss **Foreur Maudit** : arene "atelier de forage", attaques charge frontale / tir de boulons / mine posee (explosion differee), phase rage a bas HP (Q051). Decors galeries sombres en 2D standard ; l'overlay d'obscurite (entree dediee ci-dessus) requiert un fond lisible meme assombri.
- priorite: basse (monte en haute a l'ouverture de 7a)
- statut: a_faire

### Biome 3 Iles Celestes - ennemis, boss, tileset
- phase: 7b (jalon J5)
- placeholder: assets biome 1 recolores
- specs: sprites ennemis (Q050) - Sentinelle volante (`flyer` distance), Elementaire du vent (`flyer`), Creature celeste (`flyer`), Gardien cristallin (`turret`, bouclier + zone). Boss **Orage Eternel** : arene "plateforme aerienne", attaques eclair cible (zone telegraphiee) / teleportation courte / tempete de cristaux (Q051). Decors iles flottantes/cristaux en 2D standard - biome parcouru **vers le haut**, prevoir des salles empilables verticalement (connexions top/bottom, questions.md Q032).
- priorite: basse (monte en haute a l'ouverture de 7b)
- statut: a_faire

### Biome 4 Descente vers le Noyau - ennemis, boss, tileset
- phase: 7c (jalon J6)
- placeholder: assets biome 1 recolores
- specs: sprites ennemis (Q050) - Revenant (`ground` drain de vie), Creature corrompue (`ground`/`flyer` hybride), Manifestation du Voile (`teleporter` - nouvel archetype). Boss **Gardien du Noyau** : arene "sanctuaire du Noyau", attaques charge lourde / onde de corruption / invocation de revenants, phase 2 a mi-HP (Q051). Decors roche en fusion en 2D standard - **imagerie volcanique confirmee sur ce biome** (Marteau Magmatique, Armure Volcanique, questions.md Q042), biome parcouru **vers le bas** (connexions top/bottom).
- priorite: basse (monte en haute a l'ouverture de 7c)
- statut: a_faire

### Sprites des 4 porteurs de recettes
- phase: 8 - Porteurs
- placeholder: sprites ennemis standards
- specs: Archiviste Perdu (drop Couronne Spectrale), Golem Artisan, Mineur Spectral, Forgeron Maudit (drop Armure du Noyau, Lame du Noyau) - silhouettes distinctives (rarete lisible), sources precises dans questions.md Q043
- priorite: basse
- statut: a_faire

### Modules visuels du Miroir du Noyau
- phase: 9 - Boss final (jalon J7)
- placeholder: assemblage de sprites boss existants
- specs: modules combinables selon `mirror.json` (questions.md Q052) - 4 modules biome (racines/immobilisation/invocation vegetale ; armure renforcee/charge/explosion ; deplacement aerien/eclairs/cristaux ; energie du Noyau/corruption/zone majeure) + 5 mutations cicatrice (saignement, resistance, drain, poursuite, degats eleves) ; compatibles assemblage runtime. Un Miroir genere avec un seul biome/aucune cicatrice doit rester visuellement coherent (pas de module manquant).
- priorite: basse
- statut: a_faire

### UI complementaires - barres de vie, menu options, ecran controles
- phase: 10 - Polish
- placeholder: aucun
- specs: barres de vie fines au-dessus des ennemis (questions.md Q057) ; menu options (volumes, plein ecran/fenetre, recalibration manette, Q058) ; ecran de rappel des controles manette (Q059) ; confirmation d'effacement a "Nouvelle partie" (Q060). Priorite basse - UI passe apres joueur/ennemis/boss/tilesets (Q071).
- priorite: basse
- statut: a_faire
